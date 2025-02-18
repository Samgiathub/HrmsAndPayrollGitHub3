using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0050ExportAllowance
{
    public decimal CmpId { get; set; }

    public string AdName { get; set; } = null!;

    public string AdSortName { get; set; } = null!;

    public string EarningOrDeduction { get; set; } = null!;

    public string AdCalculateOn { get; set; } = null!;

    public decimal SortingNumber { get; set; }

    public string AllowanceType { get; set; } = null!;

    public string IsPartOfCtc { get; set; } = null!;

    public string ActiveInActive { get; set; } = null!;

    public string AdDefId { get; set; } = null!;

    public string IsOptional { get; set; } = null!;

    public byte HideInReports { get; set; }
}
