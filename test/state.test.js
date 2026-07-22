import {beforeEach, describe, expect, test} from 'bun:test'

const {Localization} = await import('../.cache/test/state.js')

let storage
let requests
let routes

const delay = ms => new Promise(resolve => setTimeout(resolve, ms))

const setup = (language = 'ru-RU') => {
	storage = new Map()
	requests = []
	routes = new Map()
	globalThis.window = {
		navigator: {language},
		localStorage: {
			getItem: key => storage.get(key) ?? null,
			setItem: (key, value) => storage.set(key, String(value))
		},
		location: {href: 'http://localhost/app/'},
		URL: globalThis.URL,
		fetch: async url => {
			requests.push(String(url))
			const route = routes.get(String(url))
			if (!route) return new Response('missing', {status: 404})
			if (route.delay) await delay(route.delay)
			return Response.json(route.body)
		}
	}
}

beforeEach(() => setup())

describe('Localization bundle mode', () => {
	test('keeps the original single-file behavior', async () => {
		routes.set('http://localhost/all.json', {body: {
			en: {$: {name: 'English'}, hello: 'Hello {name}'},
			ru: {$: {name: 'Русский'}, hello: 'Привет, {name}'}
		}})
		storage.set('imba-localization', 'ru')

		const lex = new Localization('http://localhost/all.json', 'en')
		await lex.pending

		expect(lex.ready).toBe(true)
		expect(lex.active).toBe('ru')
		expect(lex.text('hello', '', {name: 'Федор'})).toBe('Привет, Федор')
		expect(requests).toEqual(['http://localhost/all.json'])
	})
})

describe('Localization split mode', () => {
	beforeEach(() => {
		routes.set('/locales/languages.json', {body: {
			default: 'en',
			languages: {
				en: {name: 'English', flag: 'gb', src: 'en.json'},
				ru: {name: 'Русский', flag: 'ru'},
				es: {name: 'Español', flag: 'es', src: 'es.json'},
				fr: {name: 'Français', flag: 'fr', src: 'fr.json'},
				de: {name: 'Deutsch', flag: 'de', src: 'de.json'}
			}
		}})
		routes.set('http://localhost/locales/ru.json', {body: {hello: 'Привет'}})
		routes.set('http://localhost/locales/en.json', {body: {hello: 'Hello'}})
		routes.set('http://localhost/locales/fr.json', {body: {hello: 'Bonjour'}, delay: 30})
		routes.set('http://localhost/locales/de.json', {body: {hello: 'Hallo'}, delay: 5})
	})

	test('loads only the selected language and caches later switches', async () => {
		const lex = new Localization('/locales/languages.json', 'en', {split: true})
		await lex.pending

		expect(lex.ready).toBe(true)
		expect(lex.active).toBe('ru')
		expect(lex.hello).toBe('Привет')
		expect(requests).toEqual([
			'/locales/languages.json',
			'http://localhost/locales/ru.json'
		])

		await lex.use('en')
		expect(lex.active).toBe('en')
		expect(lex.hello).toBe('Hello')

		const count = requests.length
		await lex.use('ru')
		expect(requests.length).toBe(count)
	})

	test('keeps the current language when a dictionary fails', async () => {
		const lex = new Localization('/locales/languages.json', 'en', {split: true})
		const errors = []
		lex.onerror = (code, details) => errors.push({code, details})
		await lex.pending
		await lex.use('en')
		await lex.use('es')

		expect(lex.active).toBe('en')
		expect(errors.at(-1)?.code).toBe('localization-no-file')
	})

	test('lets the latest language switch win a request race', async () => {
		const lex = new Localization('/locales/languages.json', 'en', {split: true})
		await lex.pending

		const french = lex.use('fr')
		const german = lex.use('de')
		await Promise.all([french, german])

		expect(lex.active).toBe('de')
		expect(lex.hello).toBe('Hallo')
	})
})
