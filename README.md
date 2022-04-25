# Flox CI integration

This repository provides adapters for CI instances building flox managed packages.
It updates the catalog of packages by evaluating a specified flake output and subsequently checks for whether the output can be queried from a specified build cache.

This function is meant to be triggered by upstream changes of the flox managed project and thereafter periodically to reflect the build status of the output.

The processing of the evaluation results and querying of the substitutor is done using the apps injected by the [capacitor](https://github.com/flox/capacitor).

This integration is used to build the initial catalog of packages for your flox instance and keep it updated with availability metadata.

## Usage

### Github Actions

This repository defines an Action that provides the right environement for the function to run with an "actiony" interface.

Please consult the action's (inputs)[./action.yml] to see how to configure the action on your repository.

## Notes

*The build status is currently updated by periodic polling, a build CI integration is expected to instead push build status updates autonomously in the future*

Since the flox capacitor is a pivate repository, nix needs an access token to pull the repository. Therefore please **set the `git_token` input to a GitHub secret in the form of: 

```
github.com=<token> 
```

where `<token>` is a valid GitHub token that grants access to the private flox capacitor.
