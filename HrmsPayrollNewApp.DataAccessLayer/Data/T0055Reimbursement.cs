using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0055Reimbursement
{
    public decimal RimbId { get; set; }

    public decimal CmpId { get; set; }

    public string RimbName { get; set; } = null!;

    public string RimbFlag { get; set; } = null!;

    public decimal RimbLevel { get; set; }

    public decimal? AdId { get; set; }

    public virtual T0050AdMaster? Ad { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0060RimbEffectAdMaster> T0060RimbEffectAdMasters { get; set; } = new List<T0060RimbEffectAdMaster>();

    public virtual ICollection<T0070ItMaster> T0070ItMasters { get; set; } = new List<T0070ItMaster>();

    public virtual ICollection<T0100RimbursementDetail> T0100RimbursementDetails { get; set; } = new List<T0100RimbursementDetail>();
}
