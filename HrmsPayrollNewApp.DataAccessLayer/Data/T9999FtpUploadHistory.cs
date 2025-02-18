using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T9999FtpUploadHistory
{
    public decimal FtpHistoryId { get; set; }

    public decimal CmpId { get; set; }

    public decimal LoginId { get; set; }

    public string? FtpUsername { get; set; }

    public string? FtpPassword { get; set; }

    public DateTime LoginDate { get; set; }

    public string? LocalIpAddress { get; set; }

    public string? GlobalIpAddress { get; set; }

    public string? MacAddress { get; set; }

    public string? FtpFileName { get; set; }

    public decimal? FileExtension { get; set; }

    public string? MobileNumber { get; set; }

    public string? Remarks { get; set; }
}
