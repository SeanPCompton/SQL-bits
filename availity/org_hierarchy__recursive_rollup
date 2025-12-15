/* Org hierarchy rollup using a recursive CTE.

   Use case:
   - Quickly materialize reporting lines for analytics / access rules / HR dashboards
   - Useful when upstream systems store only (employee_id, manager_id) edges
   

   Notes / guardrails:
   - Includes depth + path to support ordering and debugging.
   - Adds basic cycle protection to avoid infinite loops if source data is dirty.
   - A max depth is included as a safety fuse (tune as appropriate).
   - common in org hierarchy or crm data munging, save for onboarding new project resources
*/

WITH RECURSIVE org_hierarchy AS (

    -- Base: top-level employees (no manager)
    SELECT
          E.EmployeeID
        , E.Name         AS employee_name
        , E.Position     AS position
        , E.ManagerID    AS manager_id
        , CAST(E.EmployeeID AS VARCHAR(4000)) AS hierarchy_path
        , 0              AS level
        , D.DepartmentName AS department_name
        , D.Region         AS region
    FROM Employees E
    JOIN Departments D
      ON E.DepartmentID = D.DepartmentID
    WHERE E.ManagerID IS NULL

    UNION ALL

    -- Recursive: direct reports
    SELECT
          E.EmployeeID
        , E.Name         AS employee_name
        , E.Position     AS position
        , E.ManagerID    AS manager_id
        , CONCAT(OH.hierarchy_path, ' > ', CAST(E.EmployeeID AS VARCHAR(4000))) AS hierarchy_path
        , OH.level + 1   AS level
        , D.DepartmentName AS department_name
        , D.Region         AS region
    FROM Employees E
    JOIN org_hierarchy OH
      ON E.ManagerID = OH.EmployeeID
    JOIN Departments D
      ON E.DepartmentID = D.DepartmentID
    WHERE OH.level < 25
      AND OH.hierarchy_path NOT LIKE CONCAT('%', CAST(E.EmployeeID AS VARCHAR(4000)), '%')

)

SELECT
      EmployeeID
    , employee_name
    , position
    , manager_id
    , level
    , hierarchy_path
    , department_name
    , region
FROM org_hierarchy
ORDER BY
      hierarchy_path
;
