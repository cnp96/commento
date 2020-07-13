package main

import (
	"os"

	"github.com/gorilla/mux"
)

func apiRouterInit(router *mux.Router) error {
	subdir := pathStrip(os.Getenv("ORIGIN"))

	router.HandleFunc(subdir+"/api/owner/new", ownerNewHandler).Methods("POST")
	router.HandleFunc(subdir+"/api/owner/confirm-hex", ownerConfirmHexHandler).Methods("GET")
	router.HandleFunc(subdir+"/api/owner/login", ownerLoginHandler).Methods("POST")
	router.HandleFunc(subdir+"/api/owner/self", ownerSelfHandler).Methods("POST")
	router.HandleFunc(subdir+"/api/owner/delete", ownerDeleteHandler).Methods("POST")

	router.HandleFunc(subdir+"/api/domain/new", domainNewHandler).Methods("POST")
	router.HandleFunc(subdir+"/api/domain/delete", domainDeleteHandler).Methods("POST")
	router.HandleFunc(subdir+"/api/domain/clear", domainClearHandler).Methods("POST")
	router.HandleFunc(subdir+"/api/domain/sso/new", domainSsoSecretNewHandler).Methods("POST")
	router.HandleFunc(subdir+"/api/domain/list", domainListHandler).Methods("POST")
	router.HandleFunc(subdir+"/api/domain/update", domainUpdateHandler).Methods("POST")
	router.HandleFunc(subdir+"/api/domain/moderator/new", domainModeratorNewHandler).Methods("POST")
	router.HandleFunc(subdir+"/api/domain/moderator/delete", domainModeratorDeleteHandler).Methods("POST")
	router.HandleFunc(subdir+"/api/domain/statistics", domainStatisticsHandler).Methods("POST")
	router.HandleFunc(subdir+"/api/domain/import/disqus", domainImportDisqusHandler).Methods("POST")
	router.HandleFunc(subdir+"/api/domain/import/commento", domainImportCommentoHandler).Methods("POST")
	router.HandleFunc(subdir+"/api/domain/export/begin", domainExportBeginHandler).Methods("POST")
	router.HandleFunc(subdir+"/api/domain/export/download", domainExportDownloadHandler).Methods("GET")

	router.HandleFunc(subdir+"/api/commenter/token/new", commenterTokenNewHandler).Methods("GET")
	router.HandleFunc(subdir+"/api/commenter/new", commenterNewHandler).Methods("POST")
	router.HandleFunc(subdir+"/api/commenter/login", commenterLoginHandler).Methods("POST")
	router.HandleFunc(subdir+"/api/commenter/self", commenterSelfHandler).Methods("POST")
	router.HandleFunc(subdir+"/api/commenter/update", commenterUpdateHandler).Methods("POST")
	router.HandleFunc(subdir+"/api/commenter/photo", commenterPhotoHandler).Methods("GET")

	router.HandleFunc(subdir+"/api/forgot", forgotHandler).Methods("POST")
	router.HandleFunc(subdir+"/api/reset", resetHandler).Methods("POST")

	router.HandleFunc(subdir+"/api/email/get", emailGetHandler).Methods("POST")
	router.HandleFunc(subdir+"/api/email/update", emailUpdateHandler).Methods("POST")
	router.HandleFunc(subdir+"/api/email/moderate", emailModerateHandler).Methods("GET")

	router.HandleFunc(subdir+"/api/oauth/google/redirect", googleRedirectHandler).Methods("GET")
	router.HandleFunc(subdir+"/api/oauth/google/callback", googleCallbackHandler).Methods("GET")

	router.HandleFunc(subdir+"/api/oauth/github/redirect", githubRedirectHandler).Methods("GET")
	router.HandleFunc(subdir+"/api/oauth/github/callback", githubCallbackHandler).Methods("GET")

	router.HandleFunc(subdir+"/api/oauth/twitter/redirect", twitterRedirectHandler).Methods("GET")
	router.HandleFunc(subdir+"/api/oauth/twitter/callback", twitterCallbackHandler).Methods("GET")

	router.HandleFunc(subdir+"/api/oauth/gitlab/redirect", gitlabRedirectHandler).Methods("GET")
	router.HandleFunc(subdir+"/api/oauth/gitlab/callback", gitlabCallbackHandler).Methods("GET")

	router.HandleFunc(subdir+"/api/oauth/sso/redirect", ssoRedirectHandler).Methods("GET")
	router.HandleFunc(subdir+"/api/oauth/sso/callback", ssoCallbackHandler).Methods("GET")

	router.HandleFunc(subdir+"/api/comment/new", commentNewHandler).Methods("POST")
	router.HandleFunc(subdir+"/api/comment/edit", commentEditHandler).Methods("POST")
	router.HandleFunc(subdir+"/api/comment/list", commentListHandler).Methods("POST")
	router.HandleFunc(subdir+"/api/comment/count", commentCountHandler).Methods("POST")
	router.HandleFunc(subdir+"/api/comment/vote", commentVoteHandler).Methods("POST")
	router.HandleFunc(subdir+"/api/comment/approve", commentApproveHandler).Methods("POST")
	router.HandleFunc(subdir+"/api/comment/delete", commentDeleteHandler).Methods("POST")

	router.HandleFunc(subdir+"/api/page/update", pageUpdateHandler).Methods("POST")

	return nil
}
