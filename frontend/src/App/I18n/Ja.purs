module App.I18n.Ja where

import Prelude

-- Sentence
did_svo :: String -> String -> String -> String
did_svo s v o = s <> "が" <> did_vo v o

did_sv :: String -> String -> String
did_sv s v = s <> "が" <> did_v v

did_vo :: String -> String -> String
did_vo v o = o <> "を" <> did_v v

did_v :: String -> String
did_v v = v <> "しました"

embrace :: String -> String
embrace x = "「" <> x <> "」"

-- General
all :: String
all = "全て"

new :: String
new = "新規"

newItem :: String
newItem = "新規項目"

addNewItem :: String
addNewItem = newItem <> "を追加"

create :: String
create = "作成"

newCreate :: String
newCreate = "新規作成"

update :: String
update = "更新"

delete :: String
delete = "削除"

deleted :: String
deleted = "削除済み"

destroy :: String
destroy = "削除"

move :: String
move = "移動"

search :: String
search = "検索"

select :: String
select = "選択"

unselect :: String
unselect = "選択解除"

cancel :: String
cancel = "キャンセル"

apply :: String
apply = "適用"

id :: String
id = "ID"

name :: String
name = "名前"

createdAt :: String
createdAt = "作成日時"

updatedAt :: String
updatedAt = "更新日時"

-- Session
login :: String
login = "ログイン"

logout :: String
logout = "ログアウト"

-- User
user :: String
user = "ユーザー名"

email :: String
email = "メールアドレス"

password :: String
password = "パスワード"

-- Pager
items :: String
items = "件"

ascending :: String
ascending = "昇順"

descending :: String
descending = "降順"

next :: String
next = "次へ"

createdAtOrder :: String
createdAtOrder = orderOf createdAt

updatedAtOrder :: String
updatedAtOrder = orderOf updatedAt

orderOf :: String -> String
orderOf x = x <> "順"
