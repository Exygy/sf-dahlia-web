import { createElement, useContext } from "react"

import { IdleTimeout, lRoute, t } from "@bloom-housing/ui-components"

// import { AppSubmissionContext } from "../../../lib/AppSubmissionContext"
import { UserContext } from "../authentication/UserContext"

const ApplicationTimeout = () => {
  const { profile } = useContext(UserContext)
  // const { conductor } = useContext(AppSubmissionContext)

  const onTimeout = () => {
    // conductor.reset()
  }

  // Only return something if the user is not logged in - otherwise we'll let the root logged in user timeout handle
  // things.
  return profile
    ? null
    : createElement(IdleTimeout, {
        promptTitle: t("t.areYouStillWorking"),
        promptText: t("application.timeout.text"),
        promptAction: t("application.timeout.action"),
        redirectPath: lRoute("/"),
        alertMessage: t("application.timeout.afterMessage"),
        alertType: "alert",
        onTimeout,
      })
}

export { ApplicationTimeout as default, ApplicationTimeout }
