from serpapi import GoogleSearch
from firebase_admin import db
import firebase_admin
from firebase_admin import credentials

cred = credentials.Certificate("Downloads/flower-hackathon-firebase-adminsdk-qg5b3-11364c2365.json")
firebase_admin.initialize_app(cred, {'databaseURL' : 'https://flower-hackathon-default-rtdb.firebaseio.com/'})

flowers_ref = db.reference("/Plants")

def update_db (hplant, snippet, title, link):
    
    flowers_ref.child(hplant).set({
            'snippet' : snippet,
            'title' : title,
            'link' : link
        })



def query_google(question):
    list_params = {
        "engine" : "google",
        "q" : question,
        "location_requested": "Basking Ridge, New Jersey, United States",
        "hl": "en",
        "gl": "us",
        "google_domain": "google.com",
        "api_key": "****************************" #it charges me money if I exceed a limit sorry :/
    }

    list_search = GoogleSearch(list_params)
    return list_search.get_dict()



def get_first_of(result):
    first_res = result['organic_results'][0]
    return first_res['title'], first_res['link']



list_results = query_google('most common houseplants')
if 'answer_box' in list_results:
    house_plants = [x.split('.')[0] for x in list_results['answer_box']['list']]
    
house_plants.append('Clematis')
house_plants.append('Virginia Creeper')
house_plants.append('Oriental Bittersweet')

for hplant in house_plants:
    results = query_google('is ' + hplant + ' an invasive species')
    
    if 'answer_box' in results and 'not' not in results['answer_box']:
        snippet = results['answer_box']['snippet']
        inv_res = query_google('how to kill ' + hplant)
        inv_title, inv_link = get_first_of(inv_res)
        update_db(hplant, snippet, inv_title, inv_link)
    else:
        save_res = query_google('how to maintain' + hplant)
        save_title, save_res = get_first_of(save_res)
        update_db(hplant, '', save_title, save_res)
