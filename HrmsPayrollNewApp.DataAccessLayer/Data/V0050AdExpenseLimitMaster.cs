using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0050AdExpenseLimitMaster
{
    public decimal AdExpMasterId { get; set; }

    public decimal CmpId { get; set; }

    public decimal AdId { get; set; }

    public string AdExpName { get; set; } = null!;

    public string MaxLimitType { get; set; } = null!;

    public decimal FixedMaxLimit { get; set; }

    public DateTime? StDateYear { get; set; }

    public int NoOfYear { get; set; }

    public DateTime CreatedDate { get; set; }

    public decimal CreatedBy { get; set; }

    public DateTime? ModifyDate { get; set; }

    public decimal? ModifyBy { get; set; }

    public string AdName { get; set; } = null!;

    public string AdSortName { get; set; } = null!;
}
