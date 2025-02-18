using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040HrmsGeneralSetting
{
    public decimal GenId { get; set; }

    public decimal? RecPostId { get; set; }

    public decimal? RecReqId { get; set; }

    public decimal ProcessId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal CmpId { get; set; }

    public decimal LoginId { get; set; }

    public decimal? ActualRate { get; set; }

    public decimal? MinRate { get; set; }

    public decimal? MaxRate { get; set; }

    public DateTime? SysDate { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0011Login Login { get; set; } = null!;

    public virtual T0040HrmsRProcessMaster Process { get; set; } = null!;

    public virtual T0052HrmsPostedRecruitment? RecPost { get; set; }
}
