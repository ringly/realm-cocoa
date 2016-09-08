def build(target, swift_version) {
  return {
    node('osx') {
      def stageName = "${target} swift-${swift_version}"
      stage(stageName) {
        // SCM
        sh 'rm -rf *'
        checkout([
          $class: 'GitSCM',
          branches: [[name: "origin/pull/${GITHUB_PR_NUMBER}/head"]],
          doGenerateSubmoduleConfigurations: false,
          extensions: [],
          gitTool: 'native git',
          submoduleCfg: [],
          userRemoteConfigs: [[
            credentialsId: '1642fb1a-1a82-4b10-a25e-f9e95f43c93f',
            name: 'origin',
            refspec: "+refs/heads/master:refs/remotes/origin/master +refs/pull/${GITHUB_PR_NUMBER}/head:refs/remotes/origin/pull/${GITHUB_PR_NUMBER}/head",
            url: 'https://github.com/realm/realm-cocoa.git'
          ]]
        ])
        sh "git submodule update --init --recursive"
        // FIXME: replace ghprbSourceBranch with sha after updating build.sh ci-pr
        sh "target=${target} swift_version=${swift_version} ghprbSourceBranch=${GITHUB_PR_SOURCE_BRANCH} ./build.sh ci-pr"
      }
    }
  }
}

try {
  node {
    step([
      $class: 'GitHubSetCommitStatusBuilder',
      statusMessage: [content: 'Jenkins CI job in progress']]
    )
  }

  parallel([
    // Swift 2.2
    osx: build('osx', '2.2'),
    docs: build('docs', '2.2'),
    ios_static: build('ios-static', '2.2'),
    ios_dynamic: build('ios-dynamic', '2.2'),
    ios_swift: build('ios-swift', '2.2'),
    osx_swift: build('osx-swift', '2.2'),
    watchos: build('watchos', '2.2'),
    cocoapods: build('cocoapods', '2.2'),
    swiftlint: build('swiftlint', '2.2'),
    tvos: build('tvos', '2.2'),
    osx_encryption: build('osx-encryption', '2.2'),

    // Swift 3.0
    osx: build('osx', '3.0'),
    docs: build('docs', '3.0'),
    ios_static: build('ios-static', '3.0'),
    ios_dynamic: build('ios-dynamic', '3.0'),
    ios_swift: build('ios-swift', '3.0'),
    osx_swift: build('osx-swift', '3.0'),
    watchos: build('watchos', '3.0'),
    cocoapods: build('cocoapods', '3.0'),
    swiftlint: build('swiftlint', '3.0'),
    tvos: build('tvos', '3.0'),
    osx_encryption: build('osx-encryption', '3.0'),
  ])

  // Mark build as successful if we get this far
  node {
    currentBuild.rawBuild.setResult(Result.SUCCESS)
  }
} finally {
  node {
    step([
      $class: 'GitHubPRBuildStatusPublisher',
      statusMsg: [content: 'Jenkins CI job finished'],
      unstableAs: 'FAILURE'
    ])
  }
}
