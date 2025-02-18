using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040BonusDeductionTypeMaster
{
    public decimal BdtypeId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? BranchId { get; set; }

    public string? BdTypeCode { get; set; }

    public string? BdTypeName { get; set; }

    public int? CreatedBy { get; set; }

    public DateTime? CreatedDate { get; set; }
}
