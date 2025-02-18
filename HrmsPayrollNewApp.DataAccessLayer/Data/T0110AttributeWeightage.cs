using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0110AttributeWeightage
{
    public decimal RowId { get; set; }

    public decimal CmpId { get; set; }

    public decimal AttrId { get; set; }

    public decimal TranId { get; set; }

    public decimal Weightage { get; set; }

    public virtual T0100EmpSkillAttrAssign Tran { get; set; } = null!;
}
