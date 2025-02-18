using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0011LoginMobileApi
{
    public decimal LoginId { get; set; }

    public decimal CmpId { get; set; }

    public string LoginName { get; set; } = null!;

    public string LoginPassword { get; set; } = null!;

    public decimal? EmpId { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? LoginRightsId { get; set; }

    public decimal? IsDefault { get; set; }

    public byte? IsHr { get; set; }

    public byte? IsAccou { get; set; }

    public string? EmailId { get; set; }

    public string? EmailIdAccou { get; set; }

    public byte IsActive { get; set; }

    public int EmpSearchType { get; set; }

    public string LoginAlias { get; set; } = null!;

    public DateTime? EffectiveDate { get; set; }

    public byte? TravelHelpDesk { get; set; }

    public string? BranchIdMulti { get; set; }

    public string? EmailIdHelpDesk { get; set; }

    public decimal IsIt { get; set; }

    public string? EmailIdIt { get; set; }

    public decimal? IsMedical { get; set; }

    public string? Token { get; set; }
}
