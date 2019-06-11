[English below]

Analiza polskich meetupów o tematyce "data science", przygotowana na potrzeby mojej pracy doktorskiej
"Data science w Polsce. Etnografia społecznego świata" w dziedzinie socjologii.
Wyniki znajdą się w części 5.1. pracy.

Dane dotyczące 86 grup pobrałem przez API meetup.com w dniu 04.06.2019 r.

Całość analizy można powtórzyć w R, ładując pobrane wcześniej pliki .json i uruchamiając kolejne skrypty.
Można pobrać pliki .json samodzielnie w Jupyter Notebook. Potrzebny będzie własny token: https://secure.meetup.com/meetup_api/key/

Inspiracje:
- https://github.com/WhyR2017/meetup-harvesting, ostatecznie nie użyłem Selenium
- https://www.datacamp.com/community/tutorials/meetup-api-data-json
- https://www.digitalpoland.org/assets/publications/mapa-polskiego-ai/map-of-the-polish-ai-2019-edition-i-report.pdf

API pozwala na wyszukiwanie grup o wybranym temacie w promieniu maksymalnie 100 mil
od miejsca pobytu zapisanym w profilu osoby wyszukującej.
Można zmienić ustawienie na globalne, ale nie działa wtedy filtr kraju, 
i ilość rekodrów jest ograniczona do 500. 
Nie pozwoliło to pobrać danych o wszystkich grupach data science w Polsce.
Dlatego ręcznie zmieniałem swoją lokalizację, uruchamiając pobranie łącznie 9 razy.

[English]
Analysis of Polish meetups on "data science" topic, prepared for my PhD thesis
"Data science in Poland, ethnography of the social world" in the field of sociology.
The results will appear in section 5.1. work.

I downloaded data on 86 groups via the meetup.com API on 04.06.2019.

The analysis can be repeated in R, loading previously downloaded .json files and sourcing subsequent scripts.
You can also download .json files yourself in Jupyter Notebook. You will need your own token: https://secure.meetup.com/meetup_api/key/

Inspirations:
- https://github.com/WhyR2017/meetup-harvesting, in the end I did not use Selenium
- https://www.datacamp.com/community/tutorials/meetup-api-data-json
- https://www.digitalpoland.org/assets/publications/mapa-polskiego-ai/map-of-the-polish-ai-2019-edition-i-report.pdf

The API allows you to search for groups with a selected topic within a maximum radius of 100 miles
from the home city saved in the profile of the person searching.
You can change the setting to global, but the country filter does not work
and the number of records is limited to 500.
This did not allow to download data on all data science groups in Poland.
That's why I manually changed my location by running a total of 9 downloads.
