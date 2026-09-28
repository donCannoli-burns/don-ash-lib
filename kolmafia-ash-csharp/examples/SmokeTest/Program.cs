using KoLmafia.AshBinding;

var pwd = Environment.GetEnvironmentVariable("KOLMAFIA_PWD")
    ?? throw new InvalidOperationException(
        "Set KOLMAFIA_PWD to the current KoLmafia session pwd hash before running this example.");

var baseUrl = Environment.GetEnvironmentVariable("KOLMAFIA_URL")
    ?? "http://127.0.0.1:60080/";

using var mafia = new AshClient(pwd, new Uri(baseUrl));

Console.WriteLine($"Character:  {await mafia.MyNameAsync()}");
Console.WriteLine($"Level:      {await mafia.MyLevelAsync()}");
Console.WriteLine($"Adventures: {await mafia.MyAdventuresAsync()}");

var club = KoL.Item("seal-clubbing club");
Console.WriteLine($"Clubs available: {await mafia.AvailableAmountAsync(club)}");

// One HTTP round trip for several ASH/property reads.
var batch = new AshBatch()
    .Property("kingLiberated")
    .Call("my_meat")
    .Call("get_property", "lastAdventure");

var result = await mafia.ExecuteBatchAsync(batch);
Console.WriteLine($"kingLiberated: {result.Properties[0]}");
Console.WriteLine($"Meat:          {result.Functions[0]}");
Console.WriteLine($"lastAdventure: {result.Functions[1]}");

// Full generic escape hatch: any ASH runtime-library function can be called.
var canInteract = await mafia.CallAsync<bool>("can_interact");
Console.WriteLine($"Can interact:  {canInteract}");
