from espn_api.basketball import League
import pandas as pd
import scipy.stats
year=2021
league = League(league_id=18927521,year=year)
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
table2 = pd.DataFrame(table.stack())
#table2.to_csv("scores2"+str(year)+".csv")
table2.index.names = ['teams','for','week']
table2.columns = ['score']
df_pts_for = table2.drop(0,level='for').reset_index(level='for', drop=True)
df_pts_ag = table2.drop(1,level='for').reset_index(level='for', drop=True)
df_pts_for['Mean_Opponent'] = (df_pts_for.groupby('week')['score'].transform('sum') - df_pts_for['score'])/(len(df_pts_for.groupby('teams')['score'])-1)
df_pts_for['normalized score'] = df_pts_for['score'] - df_pts_for['Mean_Opponent']
if 0 in df_pts_for.values:
    df_pts_for = df_pts_for.drop(0,level='week')
    df_pts_for = df_pts_for[(df_pts_for.T != 0).any()]
if 0 in df_pts_ag.values:
    df_pts_ag = df_pts_ag.drop(0,level='week')
    df_pts_ag = df_pts_ag[(df_pts_ag.T != 0).any()]
df_pts_for['3_week_rolling_mean'] = df_pts_for.groupby('teams')['normalized score'].rolling(3).mean().values
df_pts_for['Margin'] = df_pts_for['score'] - df_pts_ag['score']
df_pts_for['Won?'] = 0
for i in df_pts_for.index.values:
    if df_pts_for['Margin'][i] >0:
        df_pts_for['Won?'][i] = 1
    else:
        df_pts_for['Won?'][i] = 0
df_pts_for['Cumul_wins'] = df_pts_for.groupby('teams')['Won?'].cumsum()
print(table2)


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
