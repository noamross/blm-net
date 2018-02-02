#!/usr/bin/env Rscript
library(methods)
library(tidyverse)
library(rtweet)
library(googlesheets)
library(stringi)
library(fs)
h <- here::here

if(!dir_exists(h("data"))) {
  dir_create(h("data"))
}

blm_sheet <- gs_url("https://docs.google.com/spreadsheets/d/10v26bzYoWO7bBHpToV3dihWDhxyWKruTZO9nf1fmsCQ")

blm_groups <- gs_read(blm_sheet, ws = "BLM-related groups")

write_csv(blm_groups, h("data", "blm_groups.csv"))

blm_handles <- blm_groups %>%
  filter(Type =="Twitter") %>%
  pull("Web address") %>%
  stri_replace_all_fixed("@", "")

blm_users <- lookup_users(blm_handles)

write_csv(h("data", "blm_users.csv"))

following <- get_friends(blm_users$user_id, retryonratelimit = TRUE)
followers <- get_followers(blm_users$user_id, retryonratelimit = TRUE)
bind_rows(mutate(following, relationship="following"),
          mutate(followers, relatioship="followed_by")) %>%
  write_csv(h("data", "blm_follow.csv"))

statuses <- map_dfr(blm_users$user_id, get_timeline, n=3200)
write_csv(statuses, h("data", "blm_tweets.csv"))

