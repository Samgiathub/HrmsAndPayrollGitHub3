using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T9999UserFeedback
{
    public decimal UserId { get; set; }

    public string UserName { get; set; } = null!;

    public string? CmpName { get; set; }

    public string? CmpAddress { get; set; }

    public string? Location { get; set; }

    public string? CmpTelNo { get; set; }

    public string? MobNo { get; set; }

    public string EmailId { get; set; } = null!;

    public string Comments { get; set; } = null!;

    public DateTime PostDate { get; set; }

    public string? IpAddress { get; set; }
}
