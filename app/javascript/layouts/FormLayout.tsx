import React from "react"

import Layout from "./Layout"

export interface FormLayoutProps {
  children: React.ReactNode
  assetPaths: unknown
}

const FormLayout = (props: FormLayoutProps) => (
  <Layout assetPaths={props.assetPaths}>
    <section className="bg-gray-300">
      <div className="md:mb-20 md:mt-12 mx-auto max-w-lg print:my-0 print:max-w-full">
        {props.children}
      </div>
    </section>
  </Layout>
)

export default FormLayout
