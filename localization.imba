export class Localization
	onready
	onerror
	onchange
	languages = {}
	preferred = (window..navigator..language || 'en-US').slice(0, 2)
	default
	ready = false
	err = {
		cache: {}
		throw: do(code, details)
			return if err.cache[code]
			if onerror isa Function and ready
				onerror(code, details)
			else
				console.log "Localization error:", code, details
			err.cache[code] = true
	}

	def constructor url, fallback = 'en'
		default = fallback
		window.fetch(url)
		.then(do(response) response.json!)
		.then(do(data) _finalize(data, undefined))
		.catch(do(error) _finalize(undefined, error))
		
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
				
	def _finalize data, error
		if error or !data
			err.throw('localization-no-file',error) 
		elif !data[default]
			err.throw('localization-no-default', default)
		else
			languages = data
			ready = true
			err.cache = {}
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
			err.cache = {}

export const path-arrow-down = <path d="M213.66,165.66a8,8,0,0,1-11.32,0L128,91.31,53.66,165.66a8,8,0,0,1-11.32-11.32l80-80a8,8,0,0,1,11.32,0l80,80A8,8,0,0,1,213.66,165.66Z">

tag language-selector
	state
	icons = "https://kapowaz.github.io/square-flags/flags/##.svg"
	#dropdown = false
	arrow = path-arrow-down
	passive = false
	
	def setup
		if data
			state.active = data
		else
			data = state.active

	def onselect key
		#dropdown = false
		data = key
		state.active = key

	def flag language
		const settings = language.$
		if !settings
			state.err.throw('localization-no-key', '$')
			return undefined
		const flag = settings.flag
		if !flag
			state.err.throw('localization-no-key', '$.flag')
			return undefined
		return icons.replace('##',flag)

	def name language
		const settings = language.$
		if !settings
			state.err.throw('localization-no-key', '$')
			return undefined
		const name = settings.name
		if !name
			state.err.throw('localization-no-key', '$.name')
			return undefined
		return name

	def mouseleave e
		return if passive
		const rect = self.getBoundingClientRect!
		const menu = $menu.getBoundingClientRect!
		const inside = e.clientY >= menu.bottom || e.clientY <= rect.top || (e.clientX <= rect.left and e.clientY <= rect.bottom) || (e.clientX <= menu.left and e.clientY >= menu.top) || (e.clientX >= rect.right and e.clientY <= rect.bottom) || (e.clientX >= menu.right and e.clientY >= menu.top)
		#dropdown = !inside

	def mouseenter
		return if passive
		#dropdown = true

	def click
		return if !passive
		#dropdown = !#dropdown

	css 
		$ease: 0.5s
		.container rd:8px px:15px py:8px bgc:light-dark(#000000/10, #FFFFFF/20) fw:500 fs:13px ead:$ease bd:1px solid transparent
			@.active bgc:light-dark(#000000/20, #FFFFFF/30) bd:1px solid transparent
		.flag mr:10px rd:50% w:20px h:20px bd:1px solid transparent
		.name mr:10px bd:1px solid transparent
		.arrow w:16px h:16px fill:light-dark(#000000,#FFFFFF) ml:auto scale-y:-1 bd:1px solid transparent
			@.active scale-y:1 bd:1px solid transparent
		.menu t:100% l:50% x:-50% zi:999 backdrop-filter:blur(20px) mt:2px rd:8px rd:8px py:5px bgc:light-dark(#000000/5, #FFFFFF/10) fw:500 fs:13px ead:$ease bd:1px solid transparent
		.item d:hflex ai:center px:10px py:5px rd:8px cursor:pointer bg@hover:light-dark(#000000/10, #FFFFFF/20) m:5px bd:1px solid transparent
		.icon h:20px w:20px mr:10px rd:50% bd:1px solid transparent
		.text fs:13px bd:1px solid transparent

	<self [pos:rel] @mouseenter=mouseenter @mouseleave=mouseleave @click=click>
		<div.container [pos:rel d:hcc] .active=#dropdown [cursor:pointer]=(Object(state.languages).keys > 1)>
			<img.flag src=flag(state[state.active])>
			<div.name> name(state[state.active])
			if Object(state.languages).keys > 1
				<svg.arrow [ead:$ease] .active=#dropdown viewBox="0 0 256 256">
					<{arrow}>
		
		if #dropdown and Object(state.languages).keys > 1
			<div$menu.menu [pos:abs w:100% > max-content o@off:0] ease>
				for own key, value of state.languages
					<div.item @click.trap=onselect(key) [d:none]=(key == state.active)>
						<img.icon src=flag(value)>
						<span.text> name(value)