using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0095EmpSchema
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal IncrementId { get; set; }

    public decimal SchemeId { get; set; }

    public string Type { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0095Increment Increment { get; set; } = null!;

    public virtual ICollection<T0095EmpSchema> InverseScheme { get; set; } = new List<T0095EmpSchema>();

    public virtual T0095EmpSchema Scheme { get; set; } = null!;
}
