export class Localization
	onready
	onerror
	onchange
	languages = {}
	preferred = (window..navigator..language || 'en-US').slice(0, 2)
	default

	def constructor url, dft = 'en'
		default = dft
		window.fetch(url)
		.then(do(response) response.json!)
		.then(do(data) _finalize(data, undefined))
		.catch(do(error) _finalize(undefined, error))
		
		return new Proxy self, {
			get: do(target, p, receiver)
				return Reflect.get(target, p, receiver) if self[p]
				return target.languages[p] if target.languages[p]
				return target.languages[active][p] if target.languages[active] and target.languages[active][p]
				onerror('no_localization_key', p) if onerror isa Function
				return ''
		}
				
	def _finalize data, error
		if error
			if onerror isa Function
				onerror('no_localization_file',error) 
			else
				console.log('Localization file was not loaded', error)
			return
		languages = data if data
		if !languages[default]
			if onerror isa Function
				onerror('no_default_localization', default)
			else
				console.log('There is no Localization for the default language', default)
			return
		onready! if onready isa Function

	get active
		const saved = window.localStorage.getItem('imba-localization')
		return saved if saved and languages[saved]
		return preferred if languages[preferred]
		return default 
	
	set active name
		name = name and languages[name] ? name : active
		if window.localStorage.getItem('imba-localization') != name
			window.localStorage.setItem('imba-localization', name)
			onchange(name) if onchange isa Function
		
