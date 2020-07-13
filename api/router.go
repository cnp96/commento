package main

import (
	"net/http"
	"os"

	"github.com/gorilla/handlers"
	"github.com/gorilla/mux"
)

func routesServe() error {
	router := mux.NewRouter()

	//! This doesn't seem to be working. Hence manually adding string prefix to each route.
	// subdir := pathStrip(os.Getenv("ORIGIN"))
	// if subdir != "" {
	// 	router = router.PathPrefix(subdir).Subrouter()
	// }

	if err := apiRouterInit(router); err != nil {
		return err
	}

	if err := staticRouterInit(router); err != nil {
		return err
	}

	//! TODO: This doesn't seem to handle all 404 routes
	// router.HandleFunc("*", func(w http.ResponseWriter, r *http.Request) {
	// 	http.Redirect(w, r, os.Getenv("ORIGIN")+"/dashboard", 301)
	// })

	origins := handlers.AllowedOrigins([]string{"*"})
	headers := handlers.AllowedHeaders([]string{"X-Requested-With"})
	methods := handlers.AllowedMethods([]string{"GET", "POST"})

	addrPort := os.Getenv("BIND_ADDRESS") + ":" + os.Getenv("PORT")

	logger.Infof("starting server on %s\n", addrPort)
	if err := http.ListenAndServe(addrPort, handlers.CORS(origins, headers, methods)(router)); err != nil {
		logger.Errorf("cannot start server: %v", err)
		return err
	}

	return nil
}
