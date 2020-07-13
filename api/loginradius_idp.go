package main

import (
	"io/ioutil"
	"net/http"
	"os"
	"time"

	jsonIter "github.com/json-iterator/go"
)

var jsonExtended = jsonIter.ConfigCompatibleWithStandardLibrary

type AuthService struct {
	client      *http.Client
	apiKey, url string
}
type UserProfile struct {
	Uid   string `json:"Uid"`
	Name  string `json:"FullName"`
	Email []struct {
		Type  string `json:"Type"`
		Value string `json:"Value"`
	} `json:"Email"`
	EmailVerified *bool     `json:"EmailVerified"`
	JoinDate      time.Time `json:"SignupDate"`
}

func NewLoginRadiusAuthService() *AuthService {
	return &AuthService{
		client: &http.Client{Timeout: time.Second * 2},
		apiKey: os.Getenv("IDP_APIKEY"),
		url:    os.Getenv("IDP_ENDPOINT"),
	}
}

func (service *AuthService) GetProfileByAccessToken(accessToken string) *UserProfile {
	var fields = "Uid,FullName,Email,EmailVerified,SignupDate"
	var path = "/identity/v2/auth/account?fields=" + fields + "&apiKey=" + service.apiKey
	req, _ := http.NewRequest("GET", service.url+path, nil)
	req.Header.Set("Authorization", "Bearer "+accessToken)

	client := &http.Client{}
	resp, err := client.Do(req)

	if err != nil || resp.StatusCode != 200 {
		return nil
	}

	defer resp.Body.Close()
	body, _ := ioutil.ReadAll(resp.Body)

	var profile UserProfile
	jsonExtended.Unmarshal(body, &profile)

	return &profile
}
