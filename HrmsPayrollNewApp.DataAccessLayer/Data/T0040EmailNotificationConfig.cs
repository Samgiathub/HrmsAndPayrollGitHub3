using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040EmailNotificationConfig
{
    public decimal EmailNtfId { get; set; }

    public decimal CmpId { get; set; }

    public string EmailTypeName { get; set; } = null!;

    public decimal EmailNtfSent { get; set; }

    public decimal EmailNtfDefId { get; set; }

    public byte ToManager { get; set; }

    public byte ToHr { get; set; }

    public byte ToAccount { get; set; }

    public string? OtherEmail { get; set; }

    public byte IsManagerCc { get; set; }

    public byte IsHrCc { get; set; }

    public byte IsAccountCc { get; set; }

    public string? ModuleName { get; set; }

    public string? OtherEmailBcc { get; set; }

    public byte IsMedical { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;
}
