using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100FtpDetail
{
    public int FtpId { get; set; }

    public int? CmpId { get; set; }

    public string? FtpUrl { get; set; }

    public string? FtpUserName { get; set; }

    public string? FtpPassword { get; set; }

    public string? DomainName { get; set; }

    public string? Clientcode { get; set; }

    public string? Remarks { get; set; }
}
