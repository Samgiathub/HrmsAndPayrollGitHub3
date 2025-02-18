using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0030TravelModeMaster
{
    public decimal TravelModeId { get; set; }

    public decimal CmpId { get; set; }

    public string TravelModeName { get; set; } = null!;

    public decimal LoginId { get; set; }

    public DateTime CreateDate { get; set; }

    public DateTime? ModifyDate { get; set; }

    public byte GstApplicable { get; set; }

    public decimal? ModeType { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;
}
