using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100ArApplicationDetail
{
    public decimal ArAppDetailId { get; set; }

    public decimal AdId { get; set; }

    public string? AdFlag { get; set; }

    public string? AdMode { get; set; }

    public decimal? AdPercentage { get; set; }

    public decimal? AdAmount { get; set; }

    public decimal? EAdMaxLimit { get; set; }

    public string? Comments { get; set; }

    public decimal CreatedBy { get; set; }

    public DateTime DateCreated { get; set; }

    public decimal? Modifiedby { get; set; }

    public DateTime? DateModified { get; set; }

    public string AdName { get; set; } = null!;

    public string AdSortName { get; set; } = null!;

    public string AdCalculateOn { get; set; } = null!;

    public decimal ArAppId { get; set; }

    public decimal EmpId { get; set; }

    public decimal GrdId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal? TotalAmount { get; set; }

    public decimal? AppStatus { get; set; }

    public decimal CmpId { get; set; }

    public string? EmpFullNameNew { get; set; }

    public decimal EligibilityAmount { get; set; }

    public byte IsOptional { get; set; }

    public string AdCode { get; set; } = null!;

    public string AllowanceType { get; set; } = null!;
}
