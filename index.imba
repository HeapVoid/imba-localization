export default class Localization
	onready
	onerror
	onchange
	languages = {}
	preferred = (window..navigator..language || 'en-US').slice(0, 2)
	#active
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
				return target.languages[active][p] if target.languages[active] and target.languages[active][p]
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
				onerror('no_default_localization')
			else
				console.log('There is no Localization for the default language', default)
			return
		#active = languages[preferred] ? preferred : default
		onready! if onready isa Function

	get active
		return languages[#active] ? #active : default
	
	set active name
		if languages[name]
			#active = name
			onchange(name) if onchange isa Function
		else
			console.log('Localization for the language not found', name)
