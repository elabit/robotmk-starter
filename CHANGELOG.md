# Changelog

## [1.5.0](https://github.com/elabit/robotmk-starter/compare/v1.4.3...v1.5.0) (2026-08-31)


### Features

* **lab:** a shell in the Checkmk container ([2a816e7](https://github.com/elabit/robotmk-starter/commit/2a816e7e0c2353f606e0eb070556282535846be9))

## [1.4.3](https://github.com/elabit/robotmk-starter/compare/v1.4.2...v1.4.3) (2026-08-31)


### Bug Fixes

* **lab:** the Checkmk port opened before Checkmk was there ([43f7a43](https://github.com/elabit/robotmk-starter/commit/43f7a43ff6943a08b055499c35ef6ccb008ca9b8))

## [1.4.2](https://github.com/elabit/robotmk-starter/compare/v1.4.1...v1.4.2) (2026-08-31)


### Bug Fixes

* **lab:** Checkmk did not show up in the PORTS tab ([ff542e1](https://github.com/elabit/robotmk-starter/commit/ff542e19b4474b0ff8676dd43613f26b8a1733e8))

## [1.4.1](https://github.com/elabit/robotmk-starter/compare/v1.4.0...v1.4.1) (2026-08-31)


### Bug Fixes

* **lab:** install procps — the agent's process section needs ps ([43e56f3](https://github.com/elabit/robotmk-starter/commit/43e56f3cbca74cafe9d45f79ee4537825e1734b4))
* **lab:** the desktop was unusable, and Checkmk unreachable ([5667a90](https://github.com/elabit/robotmk-starter/commit/5667a90a562862b13ee89c87f3fb41740fa13208))

## [1.4.0](https://github.com/elabit/robotmk-starter/compare/v1.3.0...v1.4.0) (2026-08-31)


### Features

* **lab:** add cmk-quickstart lab with the course suite ([a245037](https://github.com/elabit/robotmk-starter/commit/a245037dfaa08ff0034ed3a6c083b02bfc877ece))
* **lab:** add devcontainer type cmk25-split ([a287d20](https://github.com/elabit/robotmk-starter/commit/a287d20f2497b0848eeddc4560a4ee66d485d525))
* **lab:** desktop as systemd units, not a devcontainer feature ([a9a9e28](https://github.com/elabit/robotmk-starter/commit/a9a9e28ebbfeed6f3573b390144a1823ea24da7c))
* **lab:** expose cmk-quickstart to Codespaces ([a48b1b4](https://github.com/elabit/robotmk-starter/commit/a48b1b4fa2a61d6232dda4e2d76b25a363dc42b0))
* **lab:** systemd host and Checkmk server as two compose services ([acf1334](https://github.com/elabit/robotmk-starter/commit/acf1334f401b7fe7e42abacd2bfe89657621a798))


### Bug Fixes

* **dev:** say plainly that generate-all.sh needs bash 4 ([fdc14bb](https://github.com/elabit/robotmk-starter/commit/fdc14bb5121967dc6dea0263a31c2d849946a147))
* **lab:** drop the system browser from the host image ([6a768d1](https://github.com/elabit/robotmk-starter/commit/6a768d1f957b3acecb92684c9c6458c44d47f21b))
* **lab:** the preinstall check never checked anything ([ca37aaf](https://github.com/elabit/robotmk-starter/commit/ca37aaf104bdfe715aa1351c700ffa0275ab0dc6))
* **lab:** the self-check measured while the machine was still booting ([7dd0cd8](https://github.com/elabit/robotmk-starter/commit/7dd0cd8a4cdf45efae6a5caa092b2fb816380a5c))
* **lab:** the wait loop for Checkmk exited after one second ([8ca1469](https://github.com/elabit/robotmk-starter/commit/8ca14699eefb46b244693df1f2aab3d600fc656d))

## [1.3.0](https://github.com/elabit/robotmk-starter/compare/v1.2.0...v1.3.0) (2026-07-22)


### Features

* add centos to the OS matrix ([6bffacd](https://github.com/elabit/robotmk-starter/commit/6bffacdb56be407a5228f89767b1c9a5290c071e))
* add centos to the OS matrix ([4eba836](https://github.com/elabit/robotmk-starter/commit/4eba836310729355ce2245be63c856f6278febca))
* Bridge lab ([ddf121b](https://github.com/elabit/robotmk-starter/commit/ddf121bfe7d0aa7dd2f5cbbde1e4c2e78cfe9341))
* Merge pull request [#17](https://github.com/elabit/robotmk-starter/issues/17) from elabit/feat/osmatrix ([a1fcc5a](https://github.com/elabit/robotmk-starter/commit/a1fcc5a8cf77f7197e131b6182cda142d034f88c))


### Bug Fixes

* remove leftover suite-orig.robot from web-carinsurance ([d0b442a](https://github.com/elabit/robotmk-starter/commit/d0b442ab2cc37a07cdffcd5547111371a3b5add1))
* remove leftover suite-orig.robot from web-carinsurance ([335e940](https://github.com/elabit/robotmk-starter/commit/335e940fadad2e92d65b265af0bdf13ef9df3265))

## [1.2.0](https://github.com/elabit/robotmk-starter/compare/v1.1.1...v1.2.0) (2026-06-19)


### Features

* Added cmk12 lab ([7305fca](https://github.com/elabit/robotmk-starter/commit/7305fcade202dc0ee81c5b43f9abe9c1bd746534))
* Added todoMVC ([931c889](https://github.com/elabit/robotmk-starter/commit/931c889e455da085bf99763926f8e052e7daf813))
* CarInsurance ([373ba6d](https://github.com/elabit/robotmk-starter/commit/373ba6df330002344ba501862c749be2458952ca))
* Tutorial for rfmcp ([cdedbd0](https://github.com/elabit/robotmk-starter/commit/cdedbd074458a32fd048c2de06b96f7939acc23d))


### Bug Fixes

* added claude settings.json ([cdedbd0](https://github.com/elabit/robotmk-starter/commit/cdedbd074458a32fd048c2de06b96f7939acc23d))
* cmk agent install script kills scheduler before restarting ([e6a855f](https://github.com/elabit/robotmk-starter/commit/e6a855f33976debd27d9c2bef542bfa7f22c5e25))
* CMK12lab ([7305fca](https://github.com/elabit/robotmk-starter/commit/7305fcade202dc0ee81c5b43f9abe9c1bd746534))
* Generate Script now purges dest dirs ([acadf8d](https://github.com/elabit/robotmk-starter/commit/acadf8d4e3e9ecd39cb258638a84ee64999e3a99))
* lab ([7305fca](https://github.com/elabit/robotmk-starter/commit/7305fcade202dc0ee81c5b43f9abe9c1bd746534))
* Lab examples ([9dd41a2](https://github.com/elabit/robotmk-starter/commit/9dd41a2b37a3f14544a6db4dad37b66c8c4041a3))
* links in repo tables ([09ebc57](https://github.com/elabit/robotmk-starter/commit/09ebc5742194e7af24ae553663f4c7296b43e80f))
* removed webshop example ([e6a855f](https://github.com/elabit/robotmk-starter/commit/e6a855f33976debd27d9c2bef542bfa7f22c5e25))
* removed webshop, fix agend install script, rfbrowser init ([e6a855f](https://github.com/elabit/robotmk-starter/commit/e6a855f33976debd27d9c2bef542bfa7f22c5e25))
* rfbrowser init - only chromium ([e6a855f](https://github.com/elabit/robotmk-starter/commit/e6a855f33976debd27d9c2bef542bfa7f22c5e25))
* sync script badge ([cdedbd0](https://github.com/elabit/robotmk-starter/commit/cdedbd074458a32fd048c2de06b96f7939acc23d))
* todomvc ([931c889](https://github.com/elabit/robotmk-starter/commit/931c889e455da085bf99763926f8e052e7daf813))
* TodoMVC ([931c889](https://github.com/elabit/robotmk-starter/commit/931c889e455da085bf99763926f8e052e7daf813))

## [1.1.1](https://github.com/elabit/robotmk-starter/compare/v1.1.0...v1.1.1) (2026-05-20)


### Bug Fixes

* improved rf-mcp lab ([a1550f8](https://github.com/elabit/robotmk-starter/commit/a1550f8411da83c114bf295addfdeaeb1203f995))
* renamed the labs ([62ddc73](https://github.com/elabit/robotmk-starter/commit/62ddc737a9624a95ea38c86ea6289e79fe0d9c58))

## [1.1.0](https://github.com/elabit/robotmk-starter/compare/v1.0.1...v1.1.0) (2026-05-20)


### Features

* Added rf-mcp lab ([2815d62](https://github.com/elabit/robotmk-starter/commit/2815d628406358de27d9663d9b88e81b35e7ddf0))

## [1.0.1](https://github.com/elabit/robotmk-starter/compare/v1.0.0...v1.0.1) (2026-05-20)


### Bug Fixes

* Refactored env settings ([693f86d](https://github.com/elabit/robotmk-starter/commit/693f86debfcd93e026da74a13bb10533bb3c5ba5))

## 1.0.0 (2026-05-20)


### Features

* Checkmk devcontainer ([291dba2](https://github.com/elabit/robotmk-starter/commit/291dba2c83db0ac71e6b2baec5cb2ea7a7189546))
* devcontainer type from RMK_HEADLESS var ([1c08fa1](https://github.com/elabit/robotmk-starter/commit/1c08fa18e1039ca51edbbcc41c13800d13d0392d))
* Lab environment SLAC26 ([08b7279](https://github.com/elabit/robotmk-starter/commit/08b727951b5c94f4e9887e792186afc701f5f7d7))
* Lab environment SLAC26 ([03d5134](https://github.com/elabit/robotmk-starter/commit/03d5134893e97b94f0b0ff69e0059b17bdb8078e))
* README templating ([a737347](https://github.com/elabit/robotmk-starter/commit/a7373476f38abe3eeb8173d4dfa24b71fac0af0b))
* reorganized content, better readme ([6b76d91](https://github.com/elabit/robotmk-starter/commit/6b76d91bb4a711b24864709f6a9befc90f5f63d6))
* Repo-Sync ([e092786](https://github.com/elabit/robotmk-starter/commit/e0927861c3336dac9bf475d8428c7c128983a9ab))
* Template: web-browserlibrary ([cc3f5f1](https://github.com/elabit/robotmk-starter/commit/cc3f5f1b2907ff37f7b6f49669b9a06e40f9873a))
* test blacklist ([ac1cd72](https://github.com/elabit/robotmk-starter/commit/ac1cd72068b909420fb3917ec826378b5761d699))
* update README ([250a2ea](https://github.com/elabit/robotmk-starter/commit/250a2ea1b5685fa5d8ddbdf5840d55e78b74f3a4))


### Bug Fixes

* lab workflow ([93b3daf](https://github.com/elabit/robotmk-starter/commit/93b3daf39f1f125608e65bd89c1ff29e3a7004a6))
