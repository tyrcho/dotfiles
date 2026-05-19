const googleWorkspaceHostnames = [
    "gmail.com",
    "mail.google.com",
    "drive.google.com",
    "docs.google.com",
    "sheets.google.com",
    "slides.google.com",
    "docs.new",
    "sheets.new",
    "slides.new",
    "forms.new",
]

const microsoftHostnames = [
    "login.microsoftonline.com",
    "portal.azure.com",
]


const ChromeProfiles = {
    Datadog: "Datadog",
    Personal: "Michel",
}

const GoogleIdp = {
    Dd: "C0147pk0i",
    DdVault: "1023266953562-2nltfg1vsh570fr2npin7klkn8lo3g6e.apps.googleusercontent.com",
};

export default {
    defaultBrowser: {
        name: "Google Chrome",
        profile: ChromeProfiles.Datadog,
    },
    handlers: [
        {
            match: finicky.matchHostnames(["accounts.google.com"]),
            browser: ({ urlString }) => ({
                name: "Google Chrome",
                profile: urlString.includes(GoogleIdp.Dd) || urlString.includes(GoogleIdp.DdVault)
                    ? ChromeProfiles.Datadog
                    : ChromeProfiles.Personal,
            }),
        },
        {
            match: finicky.matchHostnames([
                "github.com",
                "cs.github.com",
                "gist.github.com",
                "app.datadoghq.com",
                "ddstaging.datadoghq.com",
                "datadoghq.atlassian.net",
                "mcp.atlassian.com",
                "sdp.ddbuild.io",
                "datadog.zoom.us",
                "dd.datad0g.com",
                "gitlab.ddbuild.io",
                "mosaic.us1.ddbuild.io",
                "dd.slack.com",
                "dd.enterprise.slack.com",
                "datadog.pagerduty.com",
                "cnap-api.sdm.ddbuild.io",
                "cnab-api-sdm1.ddbuild.io",
                "signin.aws.amazon.com",
            ]),
            browser: {
                name: "Google Chrome",
                profile: ChromeProfiles.Datadog,
            },
        },
        {
            match: finicky.matchHostnames([
                ...googleWorkspaceHostnames,
                ...microsoftHostnames,
            ]),
            browser: {
                name: "Google Chrome",
                profile: ChromeProfiles.Datadog,
            },
        },
        {
            match: finicky.matchHostnames([
                "facebook.com",
                "youtube.com",
                "x.com",
                "mtg.wiki",
            ]),
            browser: {
                name: "Google Chrome",
                profile: ChromeProfiles.Personal,
            },
        },
        {
            match: /zoom\.us\/j/,
            browser: "us.zoom.xos"
        },
    ],
};

