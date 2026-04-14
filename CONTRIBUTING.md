Contribution are welcomed.

Here are the recommended steps to contribute to this widget:

1. fork this repository.
2. download the repository: `git clone https://github.com/<YOUR-USERNAME>/ip_address.git`
3. enter the project directory: `cd ip_address`
4. create a new branch: `git branch -d YOUR-BRANCH-NAME`
5. do the necessary edits and commit them.
6. push the branch to your remote: `git push origin YOUR-BRANCH-NAME`
7. open the Pull Request.

PRs are welcomed. However, each PR should be concise and on point with its intended goal. If a PR claims to implement `feature A` but it also modifies other parts of the code unnecessarely, than it is doing too much and I won't merge it.


**<ins>NOTE about AI-LLM usage</ins>**: I have nothing against the use of these tools. However, many people are unable to properly control their outputs. In practice, these tools often modifies too much. With this in mind:

* If there is a comment in the code, it is very likely to be important to me (the maintainer). Equally important are variable names, function names etc. If the LLM is going to change variable names, remove comments or reorganize the code just for the sake of it, I'll close the PR immediately.
* I prefer that you code manually and understand exactly what you are doing. Remember that at this moment, testing is done manually after each edit, which is time consuming.
