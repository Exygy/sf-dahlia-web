import React from "react"

import { SignInForm } from "../authentication/SignInForm"
import { LoggedInUserIdleTimeout } from "../authentication/timeout"
import { UserProvider } from "../authentication/UserContext"
import { withAppSetup } from "../layouts/app_settings"
import FormsLayout from "../layouts/FormLayout"

const component = () => {
  return (
    <FormsLayout>
      <UserProvider>
        <LoggedInUserIdleTimeout onTimeout={() => console.log("Logout")} />
        <SignInForm />
      </UserProvider>
    </FormsLayout>
  )
}

const SignIn = withAppSetup(component)

export { SignIn as default, SignIn }
