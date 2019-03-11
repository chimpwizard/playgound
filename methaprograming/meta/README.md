# Code generation with meta cli

```yaml
by: иÐгü
email: ndru@chimpwizard.com
date: 03.07.2019
version: draft
```

---

Methaprograming is for lazy coders, as a great coders the goal is to produce the best functionality with less typing, so if you have the same opinion methaprograming is dedicated to achieve that.

This POC goal is to explore how to extend the meta cli framework.

## Install

- npm run meta-install
- npm run meta-link-all-global
- npm i -g

## Throubleshooting

### cannot find file

There is a bug on the find-module-bin that can be fixed adding this line

```js
if (!fs.existsSync(p)) {
  p = path.join(nmp, binFileName, 'bin', binFileName);
}
```

But for the sake of be able to use the tool as-is the solution is to clone meta and add the additiona meta-<command> as a dependency and install meta directly from the folder.

## Reference

- https://github.com/mateodelnorte/meta
- https://medium.com/@patrickleet/developing-a-plugin-for-meta-bd2e9c39882d
