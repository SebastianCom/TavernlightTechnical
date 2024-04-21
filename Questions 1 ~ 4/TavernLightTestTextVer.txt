
/*Our Lead Developer has prepared the following technical tests. Please complete it by 04/22 in a tidy manner.  Make sure to include comments in your code as to why you did certain things. Additionally, please know, we will not provide feedback on how to improve your code, we expect what you send us to be your best performance and show your full ability.
 
Q1-Q4 - Fix or improve the implementation of the below methods. */
 


/*Starter:
    Hello! Thank you for allowing me to write this test. In my background you can see that Lua is not one of my strong suits so i intend to look at this test like a 
    C++ test. However i will do my best to code my answers similarly to the question so that it is as close to Lua as possible. I apologize if there are any formatting 
    or syntax errors.

*/



/*Q1 - Fix or improve the implementation of the below methods*/
 
local function releaseStorage(player)
player:setStorageValue(1000, -1)
end
 
function onLogout(player)
if player:getStorageValue(1000) == 1 then
addEvent(releaseStorage, 1000, player)
end
return true
end

/*Q1 Answer
 
The issue i see here is that second value of setStorage will have a mismatch with the getSorage check. SetStoarge setting it to -1 where as the 
get storage is checking for it to equal 1.

Depending on intention we can do 1 of 3 things for this check to succeed
1. we can change */player:setStorageValue(1000, -1) /* to  */ player:setStorageValue(1000, 1)/* changing the second value 
OR
2. we can change */if player:getStorageValue(1000) == 1 /* to  */ if player:getStorageValue(1000) == -1/* changing the second value
OR
3. we can change */if player:getStorageValue(1000) == 1 /* to  */ if player:getStorageValue(1000) <= 1/* changing the second value

without knowing the intenton of this code i cant say for sure which option would best suit the needs of the code. 


Another issues i noticed is that there is no error handling for */if player:getStorageValue(1000) == 1 then addEvent(releaseStorage, 1000, player)/*
adding an else statement may not be neccesary depending on the use of the funtion but either way if the check fails there is not mechanism to handle it.
Furthermore the way this code is set up, the onLogout function will always return true. Again i do not know the intention of this code but it would make sense to me
if the function returned true when the if check was true and the function returned false if the if check was false. It would look something like this

()
*/
local function releaseStorage(player)
    player:setStorageValue(1000, 1) /*also showing fix for mismatch option 1 */
end
 
function onLogout(player)
    if player:getStorageValue(1000) == 1 then
        addEvent(releaseStorage, 1000, player)
        return true
    else
        return false
    end
end

/*Last if we are always using 1000 for the storage checks than we may want to save that as a variable. This is done not only for readability of the code but also to
try and reduce human error (i.e you accidently type an extra 0 somewhere and put 10000). I am assuming that the 1000 represents the id of a storage item so i named it
as such. However if i am wrong and it is important that in this step you name the varibale something accurate or else you will not fix the readability issue and may
create more issues if the name confuses other developers later on. The last benefit to this is that if you need to change the value of StorageId at any point you
only need to change it in one location instead of having to find and change ever 1000 throughout the code base. */

local StorageId = 1000 /*improvement to help with readability and reduce human error. */

local function releaseStorage(player)
    player:setStorageValue(StorageId, 1) /*also showing fix for mismatch option 1 */
end
 
function onLogout(player)
    if player:getStorageValue(StorageId) == 1 then
        addEvent(releaseStorage, StorageId, player)
        return true
    else /*fix 2 so the function does not always return true */
        return false
    end
end


/*Q1 END*/


/*Q2 - Fix or improve the implementation of the below method */

function printSmallGuildNames(memberCount)
-- this method is supposed to print names of all guilds that have less than memberCount max members
local selectGuildQuery = "SELECT name FROM guilds WHERE max_members < %d;"
local resultId = db.storeQuery(string.format(selectGuildQuery, memberCount))
local guildName = result.getString("name")
print(guildName)
end

/*
Q2 Answer

So as the comment says this code prints the name of guilds that have less than the max members, i am going to assume the the Max Memebers does not refer 
to the peak of what a guild can have but rather the number of there members in total. 

I am also going to assume the memeberCount represents the  number being checked against meaning that this function is meant to return guild names where 
max_Members < memberCount.

HOWEVER if i am wrong in that assumption and its the opposite (Max being the peak of what a guild can hold and memeberCount being the current number of members) 
than the function is meant to return guild names where memberCount < max_members. If that is the case than this fix needs to be made 
*/local selectGuildQuery = "SELECT name FROM guilds WHERE max_members < %d;"  /* gets changed to */local selectGuildQuery = "SELECT name FROM guilds WHERE max_members > %d;" /*


I am going to move forward under my first assumption that the query itself is good because i believe there is a more presssing issues with this code. 

The comment for this method says that it is supposed to return ALL guilds that fit the check. To my understanding this method is only returning one guild name. 
It is not itterating through the results.

*/
 
function printSmallGuildNames(memberCount)
//-- this method is supposed to print names of all guilds that have less than memberCount max members
    local selectGuildQuery = "SELECT name FROM guilds WHERE max_members < %d;"
    local resultId = db.storeQuery(string.format(selectGuildQuery, memberCount))


    if resultId ~= nil then /* first off we should be error checking to made sure that resultId is set up properly before we handle working with it */
        
        /*Now we need to iterate thorugh our findings and print the names first we grab the first set of the results, sort of like grabbing index 0. We do this by
            call .next() and storting that data in row. Alternitavly i have heard that some data bases may need to use :fetch*/
        local row = resultId.next()

        /*So now that we have the first set of data saved into row we need to check to make sure there is actually data there. This check works so once we run out of data
        to itterate through it will return nil and we will exit this loop. However while the data is still good this loop will continue to run and do the following */
        while row ~= nil do

            /*We grab the name from row just like the original code did and then we print that name*/
            local guildName = row.getString("name")
            print(guildName)

            /*The last thing we do before starting the loop over again is setting our row variable to represent the next peiece of data from our query or in other terms
                the next guild name gained from our query. The loop will then restart and print out the data that was assinged to row in this line*/
            row = resultId.next()
        end
    else

        /*Its important to have some error handling for debugging, so if the resultId came back not right than this error line will print letting the dev know where
        the code hit an error*/
        print("Error finding guild names")

    end
end


/* I have come to understand the .next() may not be the best approach for all libraies. So i will attempt a version with fetch as well. In this option i am also going
to implement a statment to improve performance slightly in case this function is called often. From what i undestand it also helps protect against SQL injection, which
may not be 100% needed depending on the game but its is arguably an improvement to the original method*/

function printSmallGuildNames(memberCount)
    //-- this method is supposed to print names of all guilds that have less than memberCount max members
        local selectGuildQuery = "SELECT name FROM guilds WHERE max_members < ?;"

        /*Prepare Query by creating a statment*/
        local QueryStatment = db:prepare(selectGuildQuery)

        /*next we need to bind the parameter to our query so the placehold can be replaced with our actual data in memberCount. From what i understand indexing 
        in Lua starts a 1 not 0 so we will be setting the data to replace the placeholder in the first slot which means we will use index 1*/
        QueryStatment:bind_param(1, memberCount)

        /*and now we acutally execture the query*/
        local result = QueryStatment:execute()

        /*as with the other answer we now need to add some error handling basically the same thing just a different syntax to check if result equals nil/false */
        if not result then  
            print("Error finding guild names")
            return
        end

        /*and if we are succesful than we can iterate through the data we recived onvce again. Fetch is very similar to next in the sense that it grabs the next row
        of data. Really this acts almost the exact same to the other fix in the sense that we grab the first set of data. Check that it is not nil and then loop through
        said data until row does equal nil. Each time we loop through the data we print of the name*/
        local row - result:fetch(true)
        while row do
            print(row.name)
            row =  result:fetch(true)
        end

        /*close the result as its a good practice for resource management*/
        result:close()

end


/*Q2 END*/



/*Q3 - Fix or improve the name and the implementation of the below method */
 
function do_sth_with_PlayerParty(playerId, membername)
player = Player(playerId)
local party = player:getParty()
 
for k,v in pairs(party:getMembers()) do 
    if v == Player(membername) then 
        party:removeMember(Player(membername))
    end
end
end


/*
    Q3 Answer

    So for starters lets break down this function. From what i understand this is a function to remove a specific player from a party. 
    
    What is does is it first gets the player from the playerID passed into the fuction. Then with the player the function just created it uses the 
    get party function to get the party that the player is in. 
    
    Next it uses pairs to check the party. It uses pair K and V. Where k represents the party and V represents the member saved in membername.
    So then we jump into the if check. This if check loops thorugh each member of the party and checks if they are equal to the membername variable passed in.

    If it find the player with the correct member name it removes them from the party. 

    So whats the issue?

    Well first off membername is not camel cased which does not fit any of the other code and makes the code less reaable to we can make that fix by simple capitalizing
    the N in name  -> memberName

    Next player is not actually declared in this function which has the potential to create scope issues if there are any other variables of the same name. So to fix this
    we decale player as a local variable

    Next issue is that we are creating the player based of Player(memberName) each itteration of the loop which can be improved. We can create the player from member name
    before the loop and then use that variable instead of creating it multiple times. We can do the same with the party members, this can also help readability.

    As always we should add some error handling to debug incase the loop is not running so we will ensure that our new party members variable is not nil

    And last as we are only really removing one player. meaning that if we hit that player and remove them there is no reason to continue the loop. Furthermore
    continuing to loop after removing the member can cause unexpected issues. We can fix this by adding a break once we have removed the player such that we exit the loop


*/

function do_sth_with_PlayerParty(playerId, memberName)
    local player = Player(playerId) -- added local here to make a local variable for the player
    local party = player:getParty()
    local memberToRemove = Player(memberName) -- created variable for member to remove here so that it does not need to be created each iteration of the loop
    local partyMembers = party:getMembers() -- created party members varible here for readability and error handling

    if partyMembers == nil then -- this is the error handling not 100% needed for the code to run.
        print("Error getting party Members")
        return
    end 
     
    for k,v in pairs(partyMembers) do 
        if v == memberToRemove then 
            party:removeMember(memberToRemove)
            break -- this allows us to leave the loop once we have removed the player in question
        end
    end
end
 
/*Q3 END*/



/*Q4 - Assume all method calls work fine. Fix the memory leak issue in below method*/
 
void Game::addItemToPlayer(const std::string& recipient, uint16_t itemId)
{
Player* player = g_game.getPlayerByName(recipient);
if (!player) {
player = new Player(nullptr);
if (!IOLoginData::loadPlayerByName(player, recipient)) {
return;
}
}
 
Item* item = Item::CreateItem(itemId);
if (!item) {
    return;
}
 
g_game.internalAddItem(player->getInbox(), item, INDEX_WHEREEVER, FLAG_NOLIMIT);
 
if (player->isOffline()) {
    IOLoginData::savePlayer(player);
}
}

/*
    Q4 Answer

    So as the name states this appears to be a function that adds items to the players inventory. As this is not a assment of the function ill do a quick breakdown
    First this function get the player using the recipient passed into the function call. If said player pointer is null a new player is created. If the player login
    data does not exist than the function ends right away. 

    The function than creates an item through a prebuilt function. If the pointer to the created item is null than the function ends. The function then adds the item to
    the players inventory. If the player is offline the last thing this function does is save the player data so the item is there when the player logs on.

    Now for memory leaks. 

    Right of the bat i can see that we are creating a new player an allocating that memory however we are never deallocating it. Or rather as i was taught when leaning 
    C++ "Every new needs a delete" and i am not seeing a delete here. 

    Now the create item is also interesting as i am not quite sure what is going on in that funciton. I assume that the code in either that function or somewhere else
    is handling the memory management for the item. Normally i would double check this to ensure that CreateItem is not creating a memory leak but i am going 
    off the assumption that when saying "Assume all method calls work fine" that included memory managment of memory that is allocated outside of the 
    provided function (addItemToPlayer).

    Because of this assumption i am going to focus on the memory leak that i can see forsure happening in this function and that the player.
    
    So with all those assumptions i see 3 areas where meory leaks could occur.

    1. After creating the player if the log in data does not exists then we leave the function without deallocating that memory. So to fix this we will deallocate 
        player before we return;

    2. If a player is successfully created we then have another potential memory leak. If the item is not created properly than the function will return without 
        deallocating the player. However is the item is not created properlly and the player is online we dont want to delete the player. So in this function we can also
        check to make sure the player is offline and if they are we can deallocate that memory before leaving. If the player is online that it is up to the rest of the game
        code to deallocate the player when it is no longer needed for the game. 
    
    3. If the player successfully creates the item and if offline than the data is again never deallocated. To fix this we deallocate the memory after saving the player data
       but this creates the issues where what happens if the player is online? Well in that case i am going to assume that this is not the only function in the game that
       uses the player data so i think having the code else where deallocate player when the game stops is a better idea. So we will only deallocate the memory if they
       are offline. 

    Last we will add some player = nullptr lines to avoid double deletion in the code.

*/

void Game::addItemToPlayer(const std::string& recipient, uint16_t itemId)
{
    Player* player = g_game.getPlayerByName(recipient);

    if (!player) 
    {
        player = new Player(nullptr);

        if (!IOLoginData::loadPlayerByName(player, recipient)) -- i am making an assumption here that this function checks to make sure the the players data exists rather than it checking if the player is online
        {
            delete player; -- memory leak fix #1
            player = nullptr; -- double deletion fix
            return;
        }
    }       
 
    Item* item = Item::CreateItem(itemId);

    if (!item) 
    {
        if (player->isOffline()) -- ensure that if the player is offline and the refrence is deallocated before we leave the funcion
        {
            delete player; -- memory leak fix #2
            player = nullptr;-- double deletion fix
        }
        return;
    }
 
    g_game.internalAddItem(player->getInbox(), item, INDEX_WHEREEVER, FLAG_NOLIMIT);
 
    if (player->isOffline()) 
    {
        IOLoginData::savePlayer(player);
        delete player; -- memory leak fix #3
        player = nullptr;-- double deletion fix
    }

    --if the player is online i am assuming that we do not want to deallocate it everytime an item is added to their inventory so i assume the player is properlly deallocated
    --when its no longer in use.
}



 
 
/*The last 3 tests require setting up & utilizing Open Source TFS & OTC, this is part of the trial itself to confirm your ability to setup a local environment 
  and basic navigation of Github.
 
Here you can find the base for TFS & OTC 
https://github.com/otland/forgottenserver - Please use the 1.4 Release of TFS for the trial
https://github.com/edubart/otclient
 
Here you can find some guides to help you
 
https://github.com/otland/forgottenserver/wiki - step by step guide for setting up the server (1.3 Release of TFS)
https://github.com/edubart/otclient/wiki/Compiling-on-Windows - step by step guide for setting up the client
 
 
Please reproduce the following 3 examples in a clean manner with comments as to why you programmed it the way you did. 

Please make sure to pay special attention to Question 6 video, we are wanting replication of the shaders in this 
ability (You can skip this question, as it is a more complex one, but its a big bonus if you manage to complete). 

Additionally please make sure to send  videos of reproduction as well as the source code cleanly in their own files and open a Git Repo (public) with 
the edits/additions/videos made. 

Also, make sure to add separated commits for these questions. Q1~Q4 can be a single commit, but Q5~Q7 should be separated.
*/
