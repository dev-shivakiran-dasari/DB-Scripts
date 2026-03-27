SELECT 
    ENS.UserID,
    U.UserName,
    ENS.EventID,
    E.EventName,
    MAX(CASE WHEN ENS.PlatformID = 1 THEN ENS.Platform_SummarisedInterval ELSE 0 END) AS 'Online',
    MAX(CASE WHEN ENS.PlatformID = 2 THEN ENS.Platform_SummarisedInterval ELSE 0 END) AS 'Print',
    MAX(CASE WHEN ENS.PlatformID = 3 THEN ENS.Platform_SummarisedInterval ELSE 0 END) AS X,
    MAX(CASE WHEN ENS.PlatformID = 4 THEN ENS.Platform_SummarisedInterval ELSE 0 END) AS YouTube
FROM Event_NotificationSetting ENS WITH (NOLOCK)
INNER JOIN [USER] U WITH (NOLOCK) ON ENS.UserID = U.UserID
INNER JOIN Event E WITH (NOLOCK) ON ENS.EventID = E.EventID
WHERE ENS.Platform_Summarised = 1 
  AND ENS.Platform_IsActive = 1 
  AND ENS.IsActive = 1
GROUP BY ENS.UserID, U.UserName, ENS.EventID, E.EventName
ORDER BY ENS.UserID;
