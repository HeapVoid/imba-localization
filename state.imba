export class Localization
	onready
	onerror
	onchange
	languages = {}
	preferred = (window..navigator..language || 'en-US').slice(0, 2)
	default
	ready = false
	mode = 'bundle'
	source = ''
	manifest = {}
	loaded = {}
	loading = {}
	pending
	#active = null
	#request = 0
	err = {
		cache: {}
		throw: do(code, details)
			return if err.cache[code]
			if onerror isa Function
				onerror(code, details)
			else
				console.log "Localization error:", code, details
			err.cache[code] = true
	}

	def constructor url, fallback = 'en', options = {}
		default = fallback
		source = url
		mode = options..split ? 'split' : 'bundle'
		pending = if mode == 'split' then _manifest! else _bundle!

		return new Proxy self, {
			get: do(target, p, receiver)
				if Reflect.has(target, p)
					return Reflect.get(target, p, receiver)
				if !target.ready
					target.err.throw("Request before localization is ready:", p)
					return
				return if target.err.cache[p]
				return target.languages[p] if target.languages[p]
				return target.languages[target.active][p] if target.languages[target.active] and target.languages[target.active][p]
				target.err.throw('localization-no-key', p)
				return ''
		}

	def render value, data = null
		let text = String(value or '')
		return text unless data and typeof data == 'object'
		text.replace /\{([^}]+)\}/g, do(_match, key)
			const value = data[key]
			if value == undefined or value == null then '' else String(value)

	def lookup path, fallback = ''
		const keys = if Array.isArray(path) then path else String(path or '').split('.').filter(do(part) part)
		let value = languages..[active] or languages..[default] or {}
		for key in keys
			if value and typeof value == 'object' and value[key] != undefined
				value = value[key]
			else
				return fallback
		value

	def text path, fallback = '', data = null
		const value = lookup(path, fallback)
		return render(value, data) if typeof value == 'string' or typeof value == 'number'
		render(fallback, data)

	def table path
		const value = lookup(path, {})
		if value and typeof value == 'object' then value else {}

	def use name
		name = name and languages[name] ? name : active
		return active unless name
		const request = ++#request
		if mode == 'split' and !loaded[name]
			unless await load(name)
				imba.commit!
				return active
		return active if request != #request
		_activate(name)

	def load name
		return false unless languages[name]
		return true if loaded[name]
		return await loading[name] if loading[name]
		loading[name] = _load(name)
		const success = await loading[name]
		delete loading[name]
		success

	def _load name
		try
			const data = await _read(_resolve(name))
			const content = if data..[name] and data[name]..$ then data[name] else data
			unless content and typeof content == 'object' and !Array.isArray(content)
				throw new Error("Localization file for {name} is not an object")
			const settings = _settings(name)
			const language = Object.assign({}, content)
			language.$ = Object.assign({}, content..$, settings)
			languages[name] = language
			loaded[name] = true
			return true
		catch error
			err.throw('localization-no-file', {language: name, url: _resolve(name), error})
			return false

	def _bundle
		try
			_finalize(await _read(source), undefined)
		catch error
			_finalize(undefined, error)

	def _manifest
		try
			const data = await _read(source)
			const catalog = data..languages
			default = data.default if data..default isa 'string'
			unless catalog and typeof catalog == 'object' and !Array.isArray(catalog) and Object.keys(catalog).length
				throw new Error('Localization manifest has no languages')
			manifest = catalog
			for own name of manifest
				languages[name] = {$: _settings(name)}
			unless languages[default]
				err.throw('localization-no-default', default)
				return
			let name = _select!
			let success = await load(name)
			if !success and name != default
				name = default
				success = await load(name)
			return unless success
			_finish(name)
		catch error
			err.throw('localization-no-file', {url: source, error})

	def _read url
		const response = await window.fetch(url)
		unless response.ok
			throw new Error("Localization request failed with status {response.status}")
		await response.json!

	def _resolve name
		const settings = _settings(name)
		const file = settings.src or "{name}.json"
		new window.URL(file, new window.URL(source, window.location.href)).toString!

	def _settings name
		const settings = manifest[name]
		return {src: settings} if settings isa 'string'
		settings or {}

	def _select
		const saved = window.localStorage.getItem('imba-localization')
		return saved if saved and languages[saved]
		return preferred if languages[preferred]
		default

	def _activate name
		return active unless languages[name] and loaded[name]
		const changed = #active != name
		#active = name
		if window.localStorage.getItem('imba-localization') != name
			window.localStorage.setItem('imba-localization', name)
		err.cache = {}
		onchange(name) if changed and onchange isa Function
		imba.commit! if ready
		#active

	def _finish name
		#active = name
		ready = true
		err.cache = {}
		onready! if onready isa Function
		onchange(name) if onchange isa Function
		imba.commit!

	def _finalize data, error
		if error or !data
			err.throw('localization-no-file', error)
		elif !data[default]
			err.throw('localization-no-default', default)
		else
			languages = data
			loaded = {}
			loaded[name] = true for own name of languages
			_finish(_select!)

	get active
		#active or _select!

	set active name
		use(name)
