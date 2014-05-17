/** @scratch /configuration/config.js/1
 * == Configuration
 * config.js is where you will find the core Grafana configuration. This file contains parameter that
 * must be set before kibana is run for the first time.
 */
define(['settings'],
       function (Settings) {


           return new Settings({

               /**
                * elasticsearch url:
                * For Basic authentication use: http://username:password@domain.com:9200
                */
               elasticsearch: "http://"+window.location.hostname+":9200",

               /**
                * graphite-web url:
                * For Basic authentication use: http://username:password@domain.com
                * Basic authentication requires special HTTP headers to be configured
                * in nginx or apache for cross origin domain sharing to work (CORS).
                * Check install documentation on github
                */

               graphiteUrl: window.location.protocol + "//"+window.location.hostname + ':' + window.location.port,

               /**
                * Multiple graphite servers? Comment out graphiteUrl and replace with
                *
                *  datasources: {
                *    data_center_us: { type: 'graphite',  url: 'http://<graphite_url>',  default: true },
                *    data_center_eu: { type: 'graphite',  url: 'http://<graphite_url>' }
                *
                }
                })
                })
