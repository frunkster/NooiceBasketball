from espn_api.basketball import League
import pandas as pd
import scipy.stats
year=2021
league = League(league_id=18927521,year=year)
data = league._fetch_league()
scores = dict()
won = dict()
scores_against = dict()
scores_list = []
def AssignValue(team, d, result):
    if team in d:
        if not isinstance(d[team], list):
            d[team] = [d[team]]
        d[team].append(result)
    else:
        d[team] = result
    return d

for week in range(20):
    for matchup in league.scoreboard(week):
        team1 = str(matchup.home_team)[5:-1]
        team2 = str(matchup.away_team)[5:-1]
        score1 = matchup.home_final_score
        score2 = matchup.away_final_score
        if score1 > score2:
            won = AssignValue(team1,won,1)
            won = AssignValue(team2,won,0)            
        else:
            AssignValue(team1,won,0)
            AssignValue(team2,won,1)        
        scores = AssignValue(team1,scores,score1)
        scores = AssignValue(team2,scores,score2)
        scores_against = AssignValue(team1,scores_against,score2)
        scores_against = AssignValue(team2,scores_against,score1)
wins = dict()
for team in league.teams:
    wins[str(team)[5:-1]] = team.wins
    wins[str(team)[5:-1]]=team.losses 

df = pd.DataFrame.from_dict(scores).T
df['for'] = 1
df2 = pd.DataFrame.from_dict(won).T
df3 = pd.DataFrame.from_dict(scores_against).T
df3['for'] = 0
df = df.append(df3).reset_index()
table = pd.pivot_table(df,index=['index','for'])
table2 = table.stack()
table2.to_csv("scores2"+str(year)+".csv")
ptsfor = df[df['for']==1].drop(columns=['for',0])
ptsfor = ptsfor.set_index('index').T
pdf = pd.DataFrame(columns=['team1','team2','pval'])
tm1 = []
tm2 = []
pv = []
for j in range(len(ptsfor.columns)):
    for i in range(len(ptsfor.columns)):
        if j < len(ptsfor.columns) and i<len(ptsfor.columns):
            team1 = ptsfor.columns[j]
            team2 = ptsfor.columns[i]
            stat, pval = scipy.stats.ttest_ind(ptsfor[team1],ptsfor[team2])
            if stat <0:
                pval = 1-0.5*pval
            elif stat ==0:
                pval=1
            else:
                pval = 0.5*pval
            tm1.append(team1)
            tm2.append(team2)
            pv.append(pval)

pdf = pd.DataFrame()
pdf['team1'] = tm1
pdf['team2'] = tm2
pdf['pvalue'] = pv
pdf.to_csv('pdf.csv')
