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
		onchange(active) if onchange isa Function

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
		
export tag ArrowIcon
	<self>
		<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256">
			<path d="M213.66,165.66a8,8,0,0,1-11.32,0L128,91.31,53.66,165.66a8,8,0,0,1-11.32-11.32l80-80a8,8,0,0,1,11.32,0l80,80A8,8,0,0,1,213.66,165.66Z">

export tag LanguageSelector
	state
	icons = "https://kapowaz.github.io/square-flags/flags/##.svg"
	#dropdown = false
	arrow = ArrowIcon

	def onselect key
		#dropdown = false
		state.active = key

	css
		$ease: 0.5s
		.main rd:8px px:15px py:8px cursor:pointer bgc:light-dark(#000000/10, #FFFFFF/20) fw:500 fs:13px ead:$ease
		.main-active bgc:light-dark(#000000/20, #FFFFFF/30)
		.main-flag mr:10px rd:50% w:20px h:20px
		.main-name mr:10px
		.main-arrow w:16px h:16px fill:light-dark(#000000,#FFFFFF) ml:auto scale-y:-1 ead:$ease
		.menu t:100% l:50% x:-50% zi:999 backdrop-filter:blur(20px) mt:2px rd:8px rd:8px py:5px bgc:light-dark(#000000/5, #FFFFFF/10) fw:500 fs:13px  ead:$ease
		.menu-item d:hflex px:10px py:5px rd:8px cursor:pointer bg@hover:light-dark(#000000/10, #FFFFFF/20) m:5px
		.menu-item-icon h:20px w:20px mr:10px rd:50%
		.menu-item-text fs:13px

	def icon country
		return icons.replace('##',country)

	def mouseleave e
		const rect = self.getBoundingClientRect!
		const menu = $menu.getBoundingClientRect!
		const inside = e.clientY >= menu.bottom || e.clientY <= rect.top || (e.clientX <= rect.left and e.clientY <= rect.bottom) || (e.clientX <= menu.left and e.clientY >= menu.top) || (e.clientX >= rect.right and e.clientY <= rect.bottom) || (e.clientX >= menu.right and e.clientY >= menu.top)
		#dropdown = !inside

	<self [pos:rel] @mouseenter=(#dropdown = true) @mouseleave=mouseleave>
		<div.main [pos:rel d:hcc] .main-active=#dropdown>
			<img.main-flag src=icon(state[state.active].$.flag)>
			<div.main-name> state.$.name
			<{arrow}.main-arrow [scale-y:1]=#dropdown>
		
		if #dropdown
			<div$menu.menu [pos:abs w:100% > max-content o@off:0] ease>
				for own key, value of state.languages
					<div.menu-item @click=onselect(key) [d:none]=(key == state.active)>
						<img.menu-item-icon src=icon(value.$.flag)>
						<span.menu-item-text> value.$.name
		
