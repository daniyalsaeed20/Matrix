# Deployment checklist (adapted from ECC deployment-patterns)

For **m4trix-docs-deploy** / `docs/sdlc/DEPLOYMENT.md`. Captain executes; agents document.

## Decide late (m4tr!x policy)

Targets may include Play Store, App Store, Firebase Hosting, Cloud Functions, Cloud Run, VPS — captain picks when ready.

## Before release

### App

- [ ] Tests / AC evidence complete  
- [ ] No secrets in repo  
- [ ] Error handling & logging without PII leaks  
- [ ] Version / build numbers set  

### Mobile (Flutter)

- [ ] Release signing configured  
- [ ] Store listings / privacy as required  
- [ ] Firebase / API prod projects pointed correctly  

### Backend / Functions (if any)

- [ ] Env validated at startup  
- [ ] Health check if HTTP service  
- [ ] Rollback plan written  
- [ ] Non-root containers if Docker used  

### Ops

- [ ] Monitoring / crash reporting noted  
- [ ] Rollback steps in DEPLOYMENT.md  
