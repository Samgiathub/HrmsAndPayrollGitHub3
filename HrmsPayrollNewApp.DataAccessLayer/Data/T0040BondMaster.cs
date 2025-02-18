using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040BondMaster
{
    public decimal BondId { get; set; }

    public decimal CmpId { get; set; }

    public string BondName { get; set; } = null!;

    public string BondShortName { get; set; } = null!;

    public decimal? BondAmount { get; set; }

    public int? NoOfInstallment { get; set; }

    public string? BondComments { get; set; }

    public string? GradeDetails { get; set; }

    public virtual ICollection<T0120BondApproval> T0120BondApprovals { get; set; } = new List<T0120BondApproval>();

    public virtual ICollection<T0140BondTransaction> T0140BondTransactions { get; set; } = new List<T0140BondTransaction>();
}
