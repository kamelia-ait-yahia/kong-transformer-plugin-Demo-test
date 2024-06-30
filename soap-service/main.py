from flask import Flask, request, Response
from lxml import etree
import logging

app = Flask(__name__)

# Configure logging to write to stdout (Docker logs)
logging.basicConfig(level=logging.DEBUG, format='%(asctime)s %(levelname)s: %(message)s')

# Predefined SOAP XML response
soap_response = '''<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
   <soapenv:Body>
      <ns:getIdentiteAltaN4EtablissementResponse xmlns:ns="http://serviceobject.service.callisto.newsys.altares.fr">
         <ns:return xsi:type="ax262:IdentiteAltaN4EtResponse" xmlns:ax276="http://finance.vo.callisto.newsys.altares.fr/xsd" xmlns:ax263="http://response.callisto.newsys.altares.fr/xsd" xmlns:ax274="http://lien.vo.callisto.newsys.altares.fr/xsd" xmlns:ax264="http://vo.callisto.newsys.altares.fr/xsd" xmlns:ax272="http://annonce.vo.callisto.newsys.altares.fr/xsd" xmlns:ax262="http://identite.response.callisto.newsys.altares.fr/xsd" xmlns:ax270="http://pcl.vo.callisto.newsys.altares.fr/xsd" xmlns:ax260="http://request.callisto.newsys.altares.fr/xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <ax263:correct>true</ax263:correct>
            <ax263:exception xsi:nil="true"/>
            <ax263:parametres xsi:type="ax264:ParametreCallistoInfo">
               <ax264:nbParametre>2</ax264:nbParametre>
               <ax264:parametre xsi:type="ax264:ParametreCallisto">
                  <ax264:nom>refClient</ax264:nom>
                  <ax264:valeur>Test</ax264:valeur>
               </ax264:parametre>
               <ax264:parametre xsi:type="ax264:ParametreCallisto">
                  <ax264:nom>sirenSiret</ax264:nom>
                  <ax264:valeur>572014199</ax264:valeur>
               </ax264:parametre>
            </ax263:parametres>
            <ax262:myInfo xsi:type="ax264:IdentiteAltaN4EtablissementInfo">
               <ax264:actif>false</ax264:actif>
               <ax264:codeFantoir xsi:nil="true"/>
               <ax264:codeIris xsi:nil="true"/>
               <ax264:codePostal xsi:nil="true"/>
               <ax264:communeCode xsi:nil="true"/>
               <ax264:complementRue xsi:nil="true"/>
               <ax264:dateCreation xsi:nil="true"/>
               <ax264:dateFermeture xsi:nil="true"/>
               <ax264:dateMajTelephone xsi:nil="true"/>
               <ax264:dateReactivation xsi:nil="true"/>
               <ax264:enseigne xsi:nil="true"/>
               <ax264:fax xsi:nil="true"/>
               <ax264:identiteDigitale xsi:type="ax264:IdentiteDigitale">
                  <ax264:nbReseauSocial>0</ax264:nbReseauSocial>
                  <ax264:nbSiteSecondaire>0</ax264:nbSiteSecondaire>
                  <ax264:sitePrincipal>www.altares.com</ax264:sitePrincipal>
                  <ax264:siteSecondaire xsi:nil="true"/>
               </ax264:identiteDigitale>
               <ax264:l1NomAdressage xsi:nil="true"/>
               <ax264:l2CompNomAdressage xsi:nil="true"/>
               <ax264:naf5Code xsi:nil="true"/>
               <ax264:naf5Libelle xsi:nil="true"/>
               <ax264:nonDiffusible>true</ax264:nonDiffusible>
               <ax264:precEvenementCode xsi:nil="true"/>
               <ax264:precEvenementDate xsi:nil="true"/>
               <ax264:precEvenementLabel xsi:nil="true"/>
               <ax264:predSiret xsi:nil="true"/>
               <ax264:raisonSociale>ALTARES - D &amp; B</ax264:raisonSociale>
               <ax264:rcs>1995B00279</ax264:rcs>
               <ax264:rubriqueFTCode xsi:nil="true"/>
               <ax264:rubriqueFTLabel xsi:nil="true"/>
               <ax264:rue xsi:nil="true"/>
               <ax264:siege>true</ax264:siege>
               <ax264:sigle xsi:nil="true"/>
               <ax264:siret>57201419900690</ax264:siret>
               <ax264:statutEirlCode xsi:nil="true"/>
               <ax264:statutEirlLabel xsi:nil="true"/>
               <ax264:succEvenementCode xsi:nil="true"/>
               <ax264:succEvenementDate xsi:nil="true"/>
               <ax264:succEvenementLabel xsi:nil="true"/>
               <ax264:succSiret xsi:nil="true"/>
               <ax264:telephone xsi:nil="true"/>
               <ax264:trEffectifEtab xsi:nil="true"/>
               <ax264:trEffectifEtabCode xsi:nil="true"/>
               <ax264:typeEtablissementCode xsi:nil="true"/>
               <ax264:typeEtablissementLabel xsi:nil="true"/>
               <ax264:typeExploitationCode xsi:nil="true"/>
               <ax264:typeExploitationLabel xsi:nil="true"/>
               <ax264:ville xsi:nil="true"/>
               <ax264:conventionCollective>La convention collective nationale applicable au personnel des bureaux d'études techniques, des cabinets d'ingénieurs-conseils et des sociétés de conseils</ax264:conventionCollective>
               <ax264:duns>275454064</ax264:duns>
               <ax264:identifiantConventionCollective>1486</ax264:identifiantConventionCollective>
               <ax264:sic1 xsi:nil="true"/>
               <ax264:sic2 xsi:nil="true"/>
               <ax264:sic3 xsi:nil="true"/>
               <ax264:sic4 xsi:nil="true"/>
               <ax264:sic5 xsi:nil="true"/>
               <ax264:sic6 xsi:nil="true"/>
            </ax262:myInfo>
         </ns:return>
      </ns:getIdentiteAltaN4EtablissementResponse>
   </soapenv:Body>
</soapenv:Envelope>'''

@app.route('/soap', methods=['POST'])
def soap_api():
    # Get the XML request payload
    soap_request = request.data
    logging.debug(f"Received SOAP request: {soap_request.decode()}")

    # No validation of request content

    # Parse the XML request
    try:
        root = etree.fromstring(soap_request)
        return Response(soap_response, mimetype='text/xml')
    except Exception as e:
        logging.error(f"Error parsing SOAP request: {e}")
        return Response("Invalid SOAP request format", status=400)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
