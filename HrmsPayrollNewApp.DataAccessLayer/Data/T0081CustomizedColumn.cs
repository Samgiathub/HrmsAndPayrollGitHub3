using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0081CustomizedColumn
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public string TableName { get; set; } = null!;

    public string ColumnName { get; set; } = null!;

    public byte Active { get; set; }

    public byte EssEditable { get; set; }

    public byte EssVisible { get; set; }

    public virtual ICollection<T0082EmpColumn> T0082EmpColumns { get; set; } = new List<T0082EmpColumn>();
}
