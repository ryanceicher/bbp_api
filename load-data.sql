INSERT INTO public."Users"(
	"UserID", "Username", "DiscordUsername", "DiscordMention", "DiscordID", "FriendlyName", "Points", "BbpsIssued", "GbpsIssued")
	VALUES (1, 'Test', 'TestUsername', '<@1234>', '1234', 'TestFriendlyName', 0, 0, 0);

INSERT INTO public."Bbps"(
	"BbpID", "UserID", "Value", "Description", "Timestamp", "IssuerID", "Forgiven")
	VALUES (1, 1, 1, 'TestDescription', '2023-07-19T08:00:00.000', 1, FALSE);