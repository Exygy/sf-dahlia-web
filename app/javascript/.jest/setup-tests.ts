import "@testing-library/jest-dom/extend-expect"

import { configure } from "enzyme"
import Adapter from "enzyme-adapter-react-16"
import { addTranslation } from "@sf-digital-services/ui-components"
import enPhrases from "../../assets/json/translations/react/en.json"
import { LanguagePrefix, loadTranslations } from "../util/languageUtil"

configure({ adapter: new Adapter() })

// see: https://jestjs.io/docs/en/manual-mocks#mocking-methods-which-are-not-implemented-in-jsdom
window.matchMedia = jest.fn().mockImplementation((query) => {
  return {
    matches: false,
    media: query,
    onchange: null,
    addListener: jest.fn(), // deprecated
    removeListener: jest.fn(), // deprecated
    addEventListener: jest.fn(),
    removeEventListener: jest.fn(),
    dispatchEvent: jest.fn(),
  }
})

loadTranslations(LanguagePrefix.English)
