using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040FormMaster
{
    public decimal FormId { get; set; }

    public decimal CmpId { get; set; }

    public string FormName { get; set; } = null!;

    public byte FormType { get; set; }

    public string FormComments { get; set; } = null!;

    public decimal? LoginId { get; set; }

    public DateTime? SystemDate { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0011Login? Login { get; set; }

    public virtual ICollection<T0100ItFormDesign> T0100ItFormDesigns { get; set; } = new List<T0100ItFormDesign>();
}
