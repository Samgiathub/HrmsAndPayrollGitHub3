using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050AdExpenseLimit
{
    public decimal AdExpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal AdExpMasterId { get; set; }

    public decimal DesigId { get; set; }

    public decimal AmountMaxLimit { get; set; }

    public DateTime CreatedDate { get; set; }

    public decimal CreatedBy { get; set; }

    public DateTime? ModifyDate { get; set; }

    public decimal? ModifyBy { get; set; }

    public virtual T0050AdExpenseLimitMaster AdExpMaster { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0040DesignationMaster Desig { get; set; } = null!;
}
