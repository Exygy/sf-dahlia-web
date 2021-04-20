import React from "react"

import {
  ExygyFooter,
  FooterNav,
  FooterSection,
  LocalizedLink,
  setSiteAlertMessage,
  SiteFooter,
  SiteHeader,
  t,
  UserNav,
} from "@bloom-housing/ui-components"
import Head from "next/head"
import SVG from "react-inlinesvg"

export interface LayoutProps {
  children: React.ReactNode
}

const signOut = () => {
  console.log("signOut")
}

const Layout = (props: LayoutProps) => {
  // TODO: get these from auth provider
  const signedIn = false

  const LANGUAGES =
    process.env.languages?.split(",")?.map((item) => ({
      prefix: item === "en" ? "" : item,
      label: t(`languages.${item}`),
    })) || []

  return (
    <div className="site-wrapper">
      <div className="site-content">
        <Head>
          <title>{t("nav.siteTitle")}</title>
        </Head>
        <SiteHeader
          skip={t("nav.skip")}
          logoSrc="/images/logo_glyph.svg"
          notice="This is a preview of our new website. We're just getting started. We'd love to get your feedback."
          title={t("nav.siteTitle")}
          languages={LANGUAGES}
        >
          <LocalizedLink href="/listings" className="navbar-item">
            {t("nav.listings")}
          </LocalizedLink>
          {/* Only show Get Assistance if housing counselor data is available */}
          {process.env.housingCounselorServiceUrl && (
            <LocalizedLink href="/housing-counselors" className="navbar-item">
              {t("nav.getAssistance")}
            </LocalizedLink>
          )}
          <UserNav
            signedIn={signedIn}
            signOut={() => {
              setSiteAlertMessage(t(`authentication.signOut.success`), "notice")
              // await router.push("/sign-in")
              signOut()
              window.scrollTo(0, 0)
            }}
          >
            <LocalizedLink href="/account/dashboard" className="navbar-item">
              {t("nav.myDashboard")}
            </LocalizedLink>
            <LocalizedLink href="/account/applications" className="navbar-item">
              {t("nav.myApplications")}
            </LocalizedLink>
            <LocalizedLink href="/account/settings" className="navbar-item">
              {t("nav.accountSettings")}
            </LocalizedLink>
          </UserNav>
        </SiteHeader>
        <main id="main-content">{props.children}</main>
      </div>

      <SiteFooter>
        <FooterNav copyright={t("footer.copyright")}>
          <div />
        </FooterNav>
        <FooterSection className="bg-black" small>
          <ExygyFooter />
        </FooterSection>
      </SiteFooter>
      <SVG src="/images/icons.svg" />
    </div>
  )
}

export default Layout
