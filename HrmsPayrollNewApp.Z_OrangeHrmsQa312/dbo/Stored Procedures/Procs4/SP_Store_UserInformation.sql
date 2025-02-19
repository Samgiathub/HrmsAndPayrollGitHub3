CREATE PROCEDURE SP_Store_UserInformation
    @IPAddress VARCHAR(45),
    @Country VARCHAR(100),
    @Region VARCHAR(100),
    @City VARCHAR(100),
    @ConnectionType VARCHAR(50),
    @Browser VARCHAR(100),
    @OperatingSystem VARCHAR(100),
    @DeviceType VARCHAR(100),
    @WeatherInfo VARCHAR(MAX),
    @Timezone VARCHAR(100),
    @Language VARCHAR(100)
AS	
BEGIN
    SET NOCOUNT ON;
	--Created by Karmesh 29042024 for user information store like IP address, Device, Browser for Security
    INSERT INTO UserInformation (IPAddress, Country, Region, City, ConnectionType, Browser, OperatingSystem, DeviceType, WeatherInfo, Timezone, Language,CreatedDate)
    VALUES (@IPAddress, @Country, @Region, @City, @ConnectionType, @Browser, @OperatingSystem, @DeviceType, @WeatherInfo, @Timezone, @Language, GETDATE());
END