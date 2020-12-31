# SQL-project

Engeto SQL projekt:

Cílem Engeto SQL projektu bylo vytvořit tabulku faktorů, které ovlivňují rychlost šíření koronaviru na úrovni jednotlivých států.

Výsledná data budou panelová, klíče budou stát (country) a den (date). Budu vyhodnocovat model, který bude vysvětlovat denní nárůsty nakažených v jednotlivých zemích. Samotné počty nakažených mi nicméně nejsou nic platné - je potřeba vzít v úvahu také počty provedených testů a počet obyvatel daného státu. Z těchto tří proměnných je potom možné vytvořit vhodnou vysvětlovanou proměnnou. Denní počty nakažených chci vysvětlovat pomocí proměnných několika typů. Každý sloupec v tabulce bude představovat jednu proměnnou. Chceme získat následující sloupce:


1. Časové proměnné
- binární proměnná pro víkend / pracovní den (binary_day)
- roční období daného dne (zakódujte prosím jako 0 až 3) (season_code)
2. Proměnné specifické pro daný stát
- hustota zalidnění - ve státech s vyšší hustotou zalidnění se nákaza může šířit rychleji (population_density)
- HDP na obyvatele - použijeme jako indikátor ekonomické vyspělosti státu (GDP_per_head)
- GINI koeficient - má majetková nerovnost vliv na šíření koronaviru? (gini)
- dětská úmrtnost - použijeme jako indikátor kvality zdravotnictví (mortaliy_under5)
- medián věku obyvatel v roce 2018 - státy se starším obyvatelstvem mohou být postiženy více (median_age_2018)
- podíly jednotlivých náboženství - použijeme jako proxy proměnnou pro kulturní specifika. Pro každé náboženství v daném státě bych chtěl procentní podíl jeho příslušníků na celkovém obyvatelstvu (Christianity, Islam, Unaffiliated_religions, Hinduism, Buddhism, Folk_religions, Other_religions, Judaism)
- rozdíl mezi očekávanou dobou dožití v roce 1965 a v roce 2015 - státy, ve kterých proběhl rychlý rozvoj mohou reagovat jinak než země, které jsou vyspělé už delší dobu (life_exp_diff)
3. Počasí (ovlivňuje chování lidí a také schopnost šíření viru)
- průměrná denní (mezi 6-18 hod.) teplota (daily_avg_temp)
- počet hodin v daném dni, kdy byly srážky nenulové (count_rain_hours)
- maximální síla větru v nárazech během dne (max_day_wind)
Data jsou čerpána z tabulek: countries, economies, life_expectancy, religions, covid19_basic_differences, covid19_tests, weather, lookup_table, viz. složka SQL-project/Data/
