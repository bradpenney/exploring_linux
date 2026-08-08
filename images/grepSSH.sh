#!/bin/bash

echo $(ps aux | grep ssh | grep -v grep | wc -l)
