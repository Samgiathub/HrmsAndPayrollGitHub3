using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0012CompanyCrtLoginMaster
{
    public decimal? CmpId { get; set; }

    public int CmpCount { get; set; }

    public DateTime? LastLoginDate { get; set; }

    public DateTime? CreateDate { get; set; }

    public string CmpName { get; set; } = null!;

    public string CmpAddress { get; set; } = null!;

    public decimal? LocId { get; set; }

    public string CmpCity { get; set; } = null!;

    public string CmpPinCode { get; set; } = null!;

    public string CmpPhone { get; set; } = null!;

    public string CmpEmail { get; set; } = null!;

    public string? CmpWeb { get; set; }

    public string DateFormat { get; set; } = null!;

    public DateTime FromDate { get; set; }

    public DateTime ToDate { get; set; }

    public string? PfNo { get; set; }

    public string? EsicNo { get; set; }

    public string? DomainName { get; set; }

    public string? ImageName { get; set; }

    public string? DefaultHoliday { get; set; }

    public string? LoginId { get; set; }

    public int ActiveEmp { get; set; }
}
